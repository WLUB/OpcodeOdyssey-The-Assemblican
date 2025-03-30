defmodule Assembler.AVR.Decoder do
  @moduledoc false

  alias Assembler.Utility
  use Assembler.AVR.Instructions.Builder, [
    Assembler.AVR.Instructions.LDI,
    Assembler.AVR.Instructions.RCALL,
    Assembler.AVR.Instructions.STS,
    Assembler.AVR.Instructions.RET,
    Assembler.AVR.Instructions.RJMP,
  ]
  import Bitwise

  @doc """
  Decode hex format into AVR-assembly.
  """
  def decode(data) when is_list(data) do
    data
    |> Enum.map(fn
      ":00000001FF" ->
        [0, 0] # EOF
      <<":", size::binary-2, address::binary-4, _record::binary-2, hex::binary>> ->
        {size, <<>>}    = Integer.parse(size, 16)    # :error on fail
        {address, <<>>} = Integer.parse(address, 16) # :error on fail

        [checksum | instructions] =
          hex
          |> Utility.split_hex()
          |> Enum.reverse()

        control_size(size, length(instructions))

        instructions =
          instructions
          # |> Enum.reverse()
          |> Enum.map(&(elem(Integer.parse(&1, 16), 0)))

        checksum =
          checksum
          |> Integer.parse(16)
          |> elem(0)

        control_checksum(checksum, instructions, address)

        instructions
    end)
    |> Utility.flatten_list()
    |> Utility.append_to_end(0)
    |> Utility.append_to_end(0)
    |> convert_to_word()
    |> deconstruct()
  end

  defp convert_to_word([], acc), do: acc
  defp convert_to_word([a, b | rest], acc \\ []),
  do:  convert_to_word(rest, acc ++ [(a <<< 8) + b])

  defp control_size(a, b) when a == b, do: :ok
  defp control_size(_, _), do: Utility.exit_msg("Not a correct size")

  defp control_checksum(a, b) when a == b, do: :ok
  defp control_checksum(_, _), do: Utility.exit_msg("Checksum not correct")
  defp control_checksum(checksum, instructions, address) do
    control_checksum(
      (
        -(
          length(instructions) + (address >>> 8) + (address &&& 0xff) + Enum.sum(instructions)
        ) &&& 0xff
      ),
      checksum
    )
  end
end
