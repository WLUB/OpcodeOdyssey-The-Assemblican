defmodule Assembler.Intel64.MachO.Symtab do
  @moduledoc """
  Helper functions for generating the LC symbol table
  and symbols. This is done for 64-bit only.
  """
  @symtab_cmd_size 24
  @symbol_size 16


  @doc """
  Load command - symbol table
  """
  def lc_symtab(symtab_offset, table_content_offset, table_content_size, n_sym) do
    <<
      0x00000002            :: little-unsigned-integer-size(32),
      @symtab_cmd_size      :: little-unsigned-integer-size(32),
      symtab_offset         :: little-unsigned-integer-size(32),
      n_sym                 :: little-unsigned-integer-size(32),
      table_content_offset  :: little-unsigned-integer-size(32),
      table_content_size    :: little-unsigned-integer-size(32)
    >>
  end

  def lc_symtab_size(), do: @symtab_cmd_size

  @doc """
  Symbol entry

  (0x01): Global
  (0x0e): Defined in a section
  """
  def sym_entry(type, name_offset, section_index \\ 1, value \\ 0) do
    <<
      name_offset   :: little-unsigned-integer-size(32),
      type          :: little-unsigned-integer-size(8),
      section_index :: little-unsigned-integer-size(8),
      0             :: little-unsigned-integer-size(16),
      value         :: little-unsigned-integer-size(64)
    >>
  end

  def sym_entry_size(), do: @symbol_size
end
