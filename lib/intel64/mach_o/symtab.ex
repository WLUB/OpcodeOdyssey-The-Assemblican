defmodule Assembler.Intel64.MachO.Symtab do
  import Bitwise
  @symtab_cmd_size 24
  @nlist_size 16

  def lc_symtab(symtab_offset, string_table_offset, strsize, nsyms) do
    <<
      0x2 :: little-unsigned-integer-size(32),
      @symtab_cmd_size :: little-unsigned-integer-size(32),
      symtab_offset :: little-unsigned-integer-size(32),
      nsyms :: little-unsigned-integer-size(32),
      string_table_offset :: little-unsigned-integer-size(32),
      strsize :: little-unsigned-integer-size(32)
    >>
  end

  def symtab_cmd_size(), do: @symtab_cmd_size

  @doc """
  (0x01): Marks the symbol as external (global).
  (0x0e): Indicates that the symbol is defined in a section.
  """
  def nlist_entry(string_offset, section_index \\ 1, value \\ 0, n_type \\ 0x0e ||| 0x01) do
    <<
      string_offset::little-unsigned-integer-size(32),
      n_type::little-unsigned-integer-size(8),
      section_index::little-unsigned-integer-size(8),
      0::little-unsigned-integer-size(16),
      value::little-unsigned-integer-size(64)
    >>
  end

  def nlist_size(), do: @nlist_size
end
