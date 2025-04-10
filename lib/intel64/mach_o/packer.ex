defmodule Assembler.Intel64.MachO.Packer do
  alias Assembler.Intel64.MachO.Header
  alias Assembler.Intel64.MachO.Segment
  alias Assembler.Intel64.MachO.Symtab
  alias Assembler.Intel64.Label
  import Bitwise

  defp symbol_entries(%{".data" => data, "global" => globals, ".text" => text, "extern" => external}) do
     Enum.reduce(data ++ text ++ external, {<<>>, 1}, fn
        %Label{section: section, name: name, section_offset: offset} = _, {entries, table_offset} ->
          section_number =
          case section do
            :data -> 2
            :text -> 1
            :extern -> 0
            _ -> raise "Unsupported section"
          end

          entry =
          0x0E
          |> bor(if(name in globals, do: 0x01, else: 0x00))
          |> bxor(if(section == :extern, do: 0x0F, else: 0x00))
          |> Symtab.sym_entry(table_offset, section_number, offset)

          {entries <> entry, table_offset + 1 + byte_size(name)}
        _, acc ->
          acc
     end)
    |> then(fn {symbol_entries, _} ->
      {symbol_entries, byte_size(symbol_entries)}
    end)
  end

  _find_references = """
  Finding labels as first or second argument.
  Returning a list of the byte offset in the section that
  the reference is defined.
  This function need to be changed in in-order to support
  more instructions.
  """
  defp find_references(target, %{".data" => data, ".text" => text}) do
    Enum.reduce(data ++ text, [], fn
      %Label{} = _, acc ->
        acc

      %_{parameters: [<<"#", label::binary>> | _], section_offset: offset}, acc when label == target ->
        acc ++ [offset + 1]

      %_{parameters: [_, <<"#", label::binary>> | _], section_offset: offset}, acc when label == target ->
        acc ++ [offset + 3]

      _, acc ->
        acc
    end)
  end

  defp relocation(%{".data" => data, ".text" => text, "extern" => external} = layout) do
    # We ordering the labels / refs
    Enum.reduce(data ++ text ++ external, {[], 0}, fn
      %Label{name: name} = label, {labels, offset} ->
        refs = find_references(name, layout)
        {
          labels ++ [struct(label, [references: refs, symbol_index: offset])],
          offset + 1
        }

      _, acc ->
        acc
    end)
    |> elem(0)
    |> Enum.map(&(Label.relocation_entry(&1)))
    |> then(fn labels ->
      reloc_entry_size  = Enum.reduce(labels, 0, &(&2 + byte_size(&1.relocation_entries)))
      reloc_entry       = Enum.reduce(labels, <<>>, &(&2 <> &1.relocation_entries))
      reloc_entry_num   = trunc(reloc_entry_size / 8)

      {reloc_entry_size, reloc_entry, reloc_entry_num}
    end)
  end

  defp table_content(%{".data" => data, ".text" => text, "extern" => external}) do
    Enum.reduce(data ++ text ++ external, {<<0>>, 0}, fn
      %Label{name: name} = _, {table_content, n_sym} ->
        {table_content <> "#{name}\0", n_sym + 1}

      _, acc ->
        acc
    end)
    |> then(fn {table_content, n_sym} ->
      {table_content, byte_size(table_content), n_sym}
    end)
  end

  @doc false
  def pack(%{".data_binary" => data_binary, ".text_binary" => text_binary} = layout) do

    text_size = byte_size(text_binary)
    data_size = byte_size(data_binary)

    {reloc_entry_size, reloc_entry, reloc_entry_num} = relocation(layout)
    {sym_entries, sym_entries_size} = symbol_entries(layout)

    header_size = Header.header_size()
    lc_symtab_size = Symtab.lc_symtab_size()
    lc_build_version = Segment.build_version({13,0,0}, {13,0,0})

    # Helper to pad strings
    pad_string = fn str ->
      padding = String.duplicate(<<0>>, 16 - byte_size(str))
      str <> padding
    end

    text_segname    = pad_string.("__TEXT")
    text_sectname   = pad_string.("__text")
    data_segname    = pad_string.("__DATA")
    data_sectname   = pad_string.("__data")

    align = fn offset, alignment ->
      rem = rem(offset, alignment)
      if rem == 0, do: offset, else: offset + (alignment - rem)
    end

    # Temporarily placeholders to calculate segment_command_size
    dummy_section = Segment.section_header("", "", 0, 0, 0, 0, 0, 0, 0)
    segment_command_size = byte_size(Segment.segment_command_with_sections(text_segname, [dummy_section, dummy_section], 0, 0, 0, 0, 0, 0, 0))
    total_load_commands_size = segment_command_size + lc_symtab_size + byte_size(lc_build_version)

    # Calculate offsets after all load commands
    current_offset          = align.(header_size + total_load_commands_size, 4)
    text_section_offset     = current_offset
    current_offset          = align.(text_section_offset + text_size, 4)
    data_section_offset     = current_offset
    current_offset          = align.(data_section_offset + data_size, 4)
    relocations_file_offset = current_offset
    current_offset          = align.(relocations_file_offset + reloc_entry_size, 4)
    symtab_offset           = current_offset
    current_offset          = align.(symtab_offset + sym_entries_size, 4)
    table_content_offset    = current_offset

    text_vmaddr     = 0
    data_vmaddr     = 0
    segment_vmaddr  = 0
    segment_vmsize  = (text_size + data_size)

    # Section headers with offsets
    text_section = Segment.section_header(
      text_sectname, text_segname,
      text_vmaddr, text_size, text_section_offset, 4, relocations_file_offset, reloc_entry_num, 0x80000400
    )

    data_section = Segment.section_header(
      data_sectname, data_segname,
      data_vmaddr, data_size, data_section_offset, 4, 0, 0, 0
    )

    segment_command = Segment.segment_command_with_sections(
      text_segname, [text_section, data_section],
      segment_vmaddr, segment_vmsize, text_section_offset, text_size + data_size,
      7, 5, 0
    )

    # Generating the symbol table and table content for the labels
    {table_content, table_content_size, n_sym} = table_content(layout)
    lc_symtab = Symtab.lc_symtab(symtab_offset, table_content_offset, table_content_size, n_sym)

    padding_between = fn (from, to) ->
      size = to - from
      if size > 0, do: :binary.copy(<<0>>, size), else: <<>>
    end

    # Final layout
    Header.header(total_load_commands_size, 3) <>
    segment_command <>
    lc_symtab <>
    lc_build_version <>
    padding_between.(header_size + total_load_commands_size, text_section_offset) <>
    text_binary <>
    padding_between.(text_section_offset + text_size, data_section_offset) <>
    data_binary <>
    padding_between.(data_section_offset + data_size, relocations_file_offset) <>
    reloc_entry <>
    padding_between.(relocations_file_offset + reloc_entry_size, symtab_offset) <>
    sym_entries <>
    padding_between.(symtab_offset + sym_entries_size, table_content_offset) <>
    table_content
  end
end
