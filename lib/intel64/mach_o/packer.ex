defmodule Assembler.Intel64.MachO.Packer do
  alias Assembler.Intel64.MachO.Header
  alias Assembler.Intel64.MachO.Segment
  alias Assembler.Intel64.MachO.Symtab
  alias Assembler.Intel64.Data

  import Bitwise

  defp nlist_entries(%{".data" => data, "global" => globals, ".text_labels" => text_labels}) do
     # Text labels
     {text_nlist_entries, table_content_offset} =
     Enum.reduce(Map.keys(text_labels), {<<>>, 1}, fn
       label, {acc, offset} ->
         entry =
         bor(0x0e, if(label in globals, do: 0x01, else: 0x00))
         |> Symtab.nlist_entry(offset, 1, text_labels[label])

         {acc <> entry, offset + 1 + byte_size(label)}
     end)

     # Data labels
     data_nlist_entries =
     Enum.reduce(data, {<<>>, 0, table_content_offset}, fn
       %Data{size: size, name: name} = _, {entries, offset, table_offset} ->
         entry =
         bor(0x0e, if(name in globals, do: 0x01, else: 0x00))
         |> Symtab.nlist_entry(table_offset, 2, offset)

         {entries <> entry, offset + size, table_offset + 1 + byte_size(name)}
     end)
     |> elem(0)

     nlist_entries = text_nlist_entries <> data_nlist_entries
     nlist_entries_size = byte_size(nlist_entries)

     {nlist_entries, nlist_entries_size}
  end

  defp relocation(%{".data" => data, ".text_labels" => text_labels}) do
    data =
    Enum.reduce(data, {[], length(Map.keys(text_labels)) - 1}, fn
      %Data{} = d, {data_list, index} ->
        {data_list ++ [struct(d, [symbol_index: index + 1])], index + 1}
    end)
    |> elem(0)
    |> Enum.map(&(Data.relocation_entry(&1)))

    reloc_entry_size  = Enum.reduce(data, 0, &(&2 + byte_size(&1.relocation_entries)))
    reloc_entry       = Enum.reduce(data, <<>>, &(&2 <> &1.relocation_entries))
    reloc_entry_num   = trunc(reloc_entry_size / 8)

    {reloc_entry_size, reloc_entry, reloc_entry_num}
  end

  @doc false
  def pack(%{".text" => code, ".data" => data, ".text_labels" => text_labels} = layout) do
    code_size = byte_size(code)

    data_binary = Enum.reduce(data, <<>>, &(&2 <> :erlang.list_to_binary(String.to_charlist(&1.data))))
    data_size = Enum.reduce(data, 0, &(&2 + &1.size))

    {reloc_entry_size, reloc_entry, reloc_entry_num} = relocation(layout)
    {nlist_entries, nlist_entries_size} = nlist_entries(layout)

    header_size = Header.header_size()
    lc_symtab_size = Symtab.symtab_cmd_size()
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
    current_offset          = align.(text_section_offset + code_size, 4)
    data_section_offset     = current_offset
    current_offset          = align.(data_section_offset + data_size, 4)
    relocations_file_offset = current_offset
    current_offset          = align.(relocations_file_offset + reloc_entry_size, 4)
    symtab_offset           = current_offset
    current_offset          = align.(symtab_offset + nlist_entries_size, 4)
    string_table_offset     = current_offset

    text_vmaddr     = 0
    data_vmaddr     = 0
    segment_vmaddr  = 0
    segment_vmsize  = (code_size + data_size)

    # Section headers with offsets
    text_section = Segment.section_header(
      text_sectname, text_segname,
      text_vmaddr, code_size, text_section_offset, 4, relocations_file_offset, reloc_entry_num, 0x80000400
    )

    data_section = Segment.section_header(
      data_sectname, data_segname,
      data_vmaddr, data_size, data_section_offset, 4, 0, 0, 0
    )

    segment_command = Segment.segment_command_with_sections(
      text_segname, [text_section, data_section],
      segment_vmaddr, segment_vmsize, text_section_offset, code_size + data_size,
      7, 5, 0
    )

    # Content table
    text_table_content = Enum.reduce(Map.keys(text_labels), <<>>, &(&2 <> "#{&1}\0"))
    data_table_content = Enum.reduce(data, <<>>, &(&2 <> "#{&1.name}\0"))
    string_table_content = <<0>> <> text_table_content <> data_table_content
    strsize = byte_size(string_table_content)

    nsyms = length(Map.keys(text_labels)) + length(data)
    lc_symtab = Symtab.lc_symtab(symtab_offset, string_table_offset, strsize, nsyms)

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
    code <>
    padding_between.(text_section_offset + code_size, data_section_offset) <>
    data_binary <>
    padding_between.(data_section_offset + data_size, relocations_file_offset) <>
    reloc_entry <>
    padding_between.(relocations_file_offset + reloc_entry_size, symtab_offset) <>
    nlist_entries <>
    padding_between.(symtab_offset + nlist_entries_size, string_table_offset) <>
    string_table_content
  end
end
