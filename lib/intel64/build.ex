defmodule Assembler.Intel64.Build do
  use Assembler.Intel64.Instruction.Builder, [
    Assembler.Intel64.Instruction.INT,
    Assembler.Intel64.Instruction.LEA,
    Assembler.Intel64.Instruction.MOV,
    Assembler.Intel64.Instruction.SYSCALL,
    Assembler.Intel64.Instruction.XOR
  ]

  alias Assembler.Intel64.MachO.Packer
  alias Assembler.Intel64.Register
  alias Assembler.Intel64.Data

  @doc false
  def build(instructions) do
    instructions
    |> group_sections()
    |> find_text_labels()
    |> encode_text_section()
  end

  @init_sections %{".text" => [], ".data" => [], "global" => [], ".text_labels" => %{}, "current" => nil}
  @doc false
  defp group_sections(asm_array) do
    asm_array
    |> Enum.reduce(@init_sections, fn
      [:global, name], sections ->
        Map.put(sections, "global", Map.fetch!(sections, "global") ++ [name])

      [:section, section], sections ->
        Map.put(sections, "current", section)

      instruction, %{"current" => ".text"} = sections ->
        Map.put(sections, ".text", sections[".text"] ++ [parse_params(instruction)])

      data, %{"current" => ".data"} = sections ->
        Map.put(sections, ".data", sections[".data"] ++ [parse_data_section(data)])
    end)
  end

  defp find_text_labels(%{".text" => text_section} = sections) do
    Enum.reduce(text_section, {[], 0, %{}}, fn
      [single], {lines, index, labels} when is_atom(single) ->
        label = Atom.to_string(single) |> String.reverse()
        case label  do
          <<":", label::binary>> ->
            label = String.reverse(label)
            Map.fetch(labels, label)
            |> case do
              {:ok, value} -> throw "Label #{label} already defined for instruction: #{value}"
              _unique -> {lines, index, Map.put(labels, label, index)}
            end

          _ ->
            {lines ++ [[single]], index + 1, labels}
        end
      line, {lines, index, labels} ->
        {lines ++ [line], index + 1, labels}
    end)
    |> then(fn {lines, _index, labels} ->
      sections
      |> Map.put(".text", lines)
      |> Map.put(".text_labels", labels)
    end)
  end

  defp encode_text_section(%{".text" => text_section, ".data" => data_section} = sections) do
    Enum.reduce(text_section, {<<>>, data_section}, fn
      # TODO: add this logic into instruction module
      [:lea, %Register{size: 64} = reg, <<"#", label::binary>>], {text, data} ->
        Enum.map(data,fn
          %Data{name: name, references: refs} = d when name == label->
            # offset of lea 64 will be 3
            offset = byte_size(text) + 3
            struct(d, [references: refs ++ [offset]])
          data -> data
        end)
        |> then(fn data ->
          encode_instruction([:lea, reg, 0])
          |> then(&(text <> &1))
          |> then(&{&1, data})
        end)

      [instruction | params], {text, data_section} ->
        encode_instruction([instruction | params])
        |> then(&(text <> &1))
        |> then(&{&1, data_section})
    end)
    |> then(fn {text, data} ->
      sections
      |> Map.put(".text", text)
      |> Map.put(".data", data)
    end)
  end

  defp encode_instruction([instruction | params]) do
    instruction
    |> Atom.to_string()
    |> String.upcase()
    |> (&Module.concat(Assembler.Intel64.Instruction, &1)).()
    |> struct([parameters: params])
    |> then(&(construct(&1)))
  end

  defp parse_data_section([label, "db" | data] = line) do
    label = Atom.to_string(label)

    case String.reverse(label) do
      <<":", label::binary>> ->
        Data.create(String.reverse(label), Enum.join(data, " "))

      _ ->
        throw "Not supported operation: #{Enum.join(line)}"
    end
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
    |> Enum.map(fn [a | b] -> [String.to_atom(a) | b] end)
  end

  def pack(binary_object, {:mach_o, :object}) do
    binary_object
    |> Packer.pack()
  end

  defp parse_params(params) when is_list(params) do
    params
    |> Enum.map(&(Register.create(&1)))
    |> Enum.map(&(parse_number(&1)))
  end

  defp parse_number(value) do
    case value do
      v when is_number(v) -> v
      <<"0x", v::binary>> -> String.to_integer(v, 16)
      <<"0b", v::binary>> -> String.to_integer(v,  2)
      number when is_binary(number) ->
        case Integer.parse(number) do
          {v, ""} -> v
          _error -> number
        end
      other -> other
    end
  end
end
