defmodule Assembler.AVR.Build do
  @moduledoc false

  use Assembler.AVR.Instructions.Builder, [
    Assembler.AVR.Instructions.LDI,
    Assembler.AVR.Instructions.RCALL,
    Assembler.AVR.Instructions.STS,
    Assembler.AVR.Instructions.RET,
    Assembler.AVR.Instructions.RJMP,
  ]

  import Assembler.Utility
  import Bitwise

  @max_bytes 0x10


  @doc false
  def encode_instruction(instructions) when is_list(instructions) do
    instructions
    |> Enum.map(fn [instruction | params] ->
      instruction
      |> Atom.to_string()
      |> String.upcase()
      |> (&Module.concat(Assembler.AVR.Instructions, &1)).()
      |> struct([parameters: params])
    end)
    |> Enum.reduce({[], 0}, fn instruction, {data, address} ->
      instruction
      |> struct([address: address])
      |> construct()
      |> then(&{data ++ [&1], address + instruction.size})
    end)
    |> elem(0)
  end

  @doc """
  Generate a HEX codes based on the instructions.
  Each line can fit 4-8 instruction based on the
  instruction size. (16 byte per row)
  """
  def generate_hex(instructions) when is_list(instructions) do
    instructions
    |> Enum.reduce([], fn
      {opcode_1, nil}, acc ->
        acc ++ [
          (opcode_1 &&& 0xff),        # Low
          (opcode_1 >>> 8) &&& 0xff   # High
        ]
      {opcode_1, opcode_2}, acc ->
        acc ++ [
          (opcode_1 &&& 0xff),        # Low
          (opcode_1 >>> 8) &&& 0xff,  # High
          (opcode_2 &&& 0xff),        # Low
          (opcode_2 >>> 8) &&& 0xff   # High
        ]
    end)
    |> Enum.chunk_every(@max_bytes)
    |> Enum.reduce({[], 0}, fn data, {hex, address} ->
      {
        hex ++ [to_hex_line(address, data)],
        address + @max_bytes
      }
    end)
    |> elem(0)
    |> append([":00000001FF"]) # EOF
  end

  _calculate_checksum = """
  Each instruction line need to have a checksum.
  """
  defp calculate_checksum(address, data) do
    checksum = length(data) + (address >>> 8) + (address &&& 0xff) + Enum.sum(data)
    (-checksum) &&& 0xff
  end

  _to_hex_line = """
  Construct instruction line.
  """
  defp to_hex_line(address, data) when length(data) <= @max_bytes do
    checksum = calculate_checksum(address, data)

    ":#{hex_format(length(data), 2)}#{hex_format(address, 4)}00" <>
    (
      data
      |> Enum.reduce(<<>>, &(&2 <> hex_format(&1, 2)))
      |> append(hex_format(checksum, 2))
    )
  end

  defp to_hex_line(_, _), do: raise "Instruction line over 16 bytes"
end
