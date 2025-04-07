defmodule Assembler.Intel64.Data do
  import Bitwise
  alias Assembler.Intel64.Data
  @enforce_keys [:name, :data, :size]
  defstruct [:name, :data, :size, :symbol_index, references: [], relocation_entries: []]

  @doc false
  def create(name, data) when is_binary(name) and is_binary(data) do
    bin_data = :erlang.list_to_binary(String.to_charlist(data))

    struct(Data, %{
      name: name,
      data: bin_data,
      size: byte_size(bin_data)
    })
  end

  @doc false
  def relocation_entry(%Data{references: refs, symbol_index: index} = data) do
    Enum.reduce(refs, <<>>, fn address, acc ->
      pcrel = 1
      length = 2
      extern = 1
      type = 1  # X86_64_RELOC_SIGNED

      packed_info =
        (index) |||
        (pcrel <<< 24) |||
        (length <<< 25) |||
        (extern <<< 27) |||
        (type <<< 28)

      acc <> <<
        address::little-unsigned-integer-size(32),
        packed_info::little-unsigned-integer-size(32)
      >>
    end)
    |> then(fn relocation_entries ->
      struct(data, [relocation_entries: relocation_entries])
    end)
  end
end
