defmodule Assembler.Intel64.MachO.Header do
  @header_size 32

  def header(load_commands_size, load_cmds_count) do
    <<
      0xfeedfacf :: little-unsigned-integer-size(32),
      0x01000007 :: little-unsigned-integer-size(32),
      3 :: little-unsigned-integer-size(32),
      1 :: little-unsigned-integer-size(32),
      load_cmds_count :: little-unsigned-integer-size(32),
      load_commands_size :: little-unsigned-integer-size(32),
      0 :: little-unsigned-integer-size(32),
      0 :: little-unsigned-integer-size(32)
    >>
  end

  def header_size, do: @header_size
end
