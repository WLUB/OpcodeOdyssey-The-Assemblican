defmodule Assembler.AVR.Build do
  @moduledoc false

  use Assembler.AVR.Instruction.Builder, [
    Assembler.AVR.Instruction.LDI,
    Assembler.AVR.Instruction.RCALL,
    Assembler.AVR.Instruction.STS,
    Assembler.AVR.Instruction.RET,
    Assembler.AVR.Instruction.RJMP,
    Assembler.AVR.Instruction.NOP
  ]

  import Assembler.Utility
  import Bitwise

  @max_bytes 0x10


  @doc false
  def parse_labels(instructions) when is_list(instructions) do
    Enum.map(instructions, fn [o | p] = _ins ->
      case String.reverse(o) do
        <<":", id::binary>> ->
          ["label", String.reverse(id) | p]
        _ ->
          [o | p]
      end
    end)
  end

  @doc """
  Converting text into instruction list.
  The function also removes all comments and
  the precompile the code.
  """
  @spec text_to_instructions(binary()) :: list()
  def text_to_instructions(data) when is_binary(data) do
    data
    |> String.downcase()
    |> String.split("\n")
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&Enum.at(String.split(&1, ";"), 0))
    |> Stream.filter(&(&1 != <<>>))
    |> Stream.map(&String.split(&1, " "))
    |> Enum.map(&Enum.filter(&1, fn x -> x != <<>> end))
    |> parse_labels()
    |> Enum.map(fn [a | b] -> [String.to_atom(a) | b] end)
  end

  @doc false
  def encode_instruction(instructions) when is_list(instructions) do
    instructions
    # We format each instruction / directive
    |> Enum.map(fn
      [:".org", address] ->
        {:directive, :org, parse_param(address)}

      [:label, name] ->
        {:label, name}

      [instruction | params] ->
        instruction
        |> Atom.to_string()
        |> String.upcase()
        |> (&Module.concat(Assembler.AVR.Instruction, &1)).()
        |> struct([parameters: params])
    end)
    # Validating and checking code placement
    |> Enum.reduce({[], 0, %{}}, fn
      {:directive, :org, new_address}, {data, address, labels} when new_address >= address ->
        {data, new_address, labels}

      {:directive, :org, _}, {_, _} ->
          raise "You are not allowed to move .org backwards"

      {:label, name}, {data, address, labels} ->
        # rjmp labels is counted in words and not bytes
        # so we div by 2
        case Map.fetch(labels, name) do
          {:ok, address} -> raise "Label: #{name} is already defined on address #{address}"
          :error -> {data, address, Map.put(labels, name, div(address - 2, 2))}
        end

      instruction, {data, address, labels} ->
        instruction
        |> struct([address: address])
        |> then(&{data ++ [&1], address + instruction.size, labels})
    end)
    |> then(fn {data, _, labels} ->
      # We need to make sure that the instruction is placed correct
      # in memory and otherwise fill the missing parts with NOP.
      Enum.reduce(data, {[], %{address: 0, size: 0}}, fn
        current, {data, prev} when (current.address == prev.address + prev.size) ->
          current
          |> struct([parameters: parse_params(current.parameters, labels)])
          |> construct()
          |> then(&{data ++ [&1], current})

        current, {data, prev} ->
          offset = div((current.address - (prev.address + prev.size)), 2)
          fillers =
            nil
            |> List.duplicate(offset)
            |> Enum.reduce({[], prev.address + prev.size}, fn _, {d, v} ->
              {d ++ [%NOP{address: v, size: 2, parameters: []}], v + 2}
            end)
            |> elem(0)
            |> Enum.map(&construct(&1))

          current
          |> struct([parameters: parse_params(current.parameters, labels)])
          |> construct()
          |> then(&{data ++ fillers ++ [&1], current})
      end)
      |> elem(0)
    end)
  end

  _parse_params = """
  Converting params into integers.
  """
  defp parse_params(params, labels) when is_list(params) and is_map(labels) do
    Enum.map(params, &parse_param(&1, labels))
  end

  _parse_param = """
  Converting param into integers.
  """
  defp parse_param(value, labels \\ %{}) do
    case value do
      v when is_number(v) -> v
      <<"0x", v::binary>> -> String.to_integer(v, 16)
      <<"0b", v::binary>> -> String.to_integer(v,  2)
      <<"r",  v::binary>> -> String.to_integer(v)
      v when is_binary(v) ->
        case Map.fetch(labels, v) do
          {:ok, address} -> address
          :error -> String.to_integer(v)
        end
    end
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
