defmodule Assembler.Intel64.MachO.Segment do
  import Bitwise
  @segment_header_size 72
  @section_header_size 80

  def segment_command_with_sections(segname, sections, vmaddr, vmsize, fileoff, filesize, maxprot, initprot, flags) do
    nsects = length(sections)
    cmdsize = @segment_header_size + nsects * @section_header_size
    <<
      0x19 :: little-unsigned-integer-size(32),
      cmdsize :: little-unsigned-integer-size(32),
      pad(segname) :: binary,
      vmaddr :: little-unsigned-integer-size(64),
      vmsize :: little-unsigned-integer-size(64),
      fileoff :: little-unsigned-integer-size(64),
      filesize :: little-unsigned-integer-size(64),
      maxprot :: little-unsigned-integer-size(32),
      initprot :: little-unsigned-integer-size(32),
      nsects :: little-unsigned-integer-size(32),
      flags :: little-unsigned-integer-size(32)
    >> <>
    Enum.reduce(sections, <<>>, &(&2 <> &1))
  end

  def section_header(sectname, segname, addr, size, offset, align, reloff, nreloc, flags, reserved1 \\ 0, reserved2 \\ 0, reserved3 \\ 0) do
    <<
      pad(sectname) :: binary,
      pad(segname) :: binary,
      addr :: little-unsigned-integer-size(64),
      size :: little-unsigned-integer-size(64),
      offset :: little-unsigned-integer-size(32),
      align :: little-unsigned-integer-size(32),
      reloff :: little-unsigned-integer-size(32),
      nreloc :: little-unsigned-integer-size(32),
      flags :: little-unsigned-integer-size(32),
      reserved1 :: little-unsigned-integer-size(32),
      reserved2 :: little-unsigned-integer-size(32),
      reserved3 :: little-unsigned-integer-size(32)
    >>
  end

  def build_version(minos \\ {13, 0, 0}, sdk \\ {13, 0, 0}) do
    <<
      0x32::little-unsigned-integer-size(32),
      24::little-unsigned-integer-size(32),
      1::little-unsigned-integer-size(32),                     # Platform
      encode_version(minos)::little-unsigned-integer-size(32), # OS
      encode_version(sdk)::little-unsigned-integer-size(32),   # SDK
      0::little-unsigned-integer-size(32)                      # tools
    >>
  end

  defp encode_version({major, minor, patch}) do
    (major <<< 16) ||| (minor <<< 8) ||| patch
  end

  def section_header_size(), do: @section_header_size

  def segment_cmd_size(nsects \\ 0) do
    @segment_header_size + nsects * @section_header_size
  end

  defp pad(str), do: str <> String.duplicate(<<0>>, 16 - byte_size(str))
end
