defmodule Assembler.Intel64.Label do
  import Bitwise
  alias Assembler.Intel64.Label
  @enforce_keys [:section, :name, :data, :size]
  defstruct [
    :section,
    :name,
    :data,
    :size,
    :symbol_index,
    section_offset: 0,
    references: [],
    relocation_entries: []
  ]

  @doc false
  def create(section, name, data \\ <<>>) when is_binary(name) and is_binary(data) do
    bin_data = :erlang.list_to_binary(String.to_charlist(data))

    struct(Label, %{
      section: section,
      name: name,
      data: bin_data,
      size: byte_size(bin_data)
    })
  end


  _get_reloc_type = """
  This is not really true, but will work for most cases
  so we will keep it as this until we get a reason to
  change it.
  """
  defp get_reloc_type(:data),   do: 1   # X86_64_RELOC_SIGNED
  defp get_reloc_type(:text),   do: 2   # X86_64_RELOC_BRANCH
  defp get_reloc_type(:extern), do: 2   # X86_64_RELOC_BRANCH

  @doc false
  def relocation_entry(%Label{section: section, references: refs, symbol_index: index} = data) do
    Enum.reduce(refs, <<>>, fn address, acc ->
      pcrel   = 1
      length  = 2
      extern  = 1
      type    = get_reloc_type(section)

      packed_info =
        (index        ) |||
        (pcrel  <<< 24) |||
        (length <<< 25) |||
        (extern <<< 27) |||
        (type   <<< 28)

      acc <>
      <<
        address     :: little-unsigned-integer-size(32),
        packed_info :: little-unsigned-integer-size(32)
      >>
    end)
    |> then(fn relocation_entries ->
      struct(data, [relocation_entries: relocation_entries])
    end)
  end
end
