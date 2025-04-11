defmodule Assembler.Intel64.Build do
  use Assembler.Intel64.Instruction.Builder, [
    Assembler.Intel64.Instruction.INT,
    Assembler.Intel64.Instruction.LEA,
    Assembler.Intel64.Instruction.MOV,
    Assembler.Intel64.Instruction.CALL,
    Assembler.Intel64.Instruction.SYSCALL,
    Assembler.Intel64.Instruction.XOR,
    Assembler.Intel64.Instruction.RET
  ]

  alias Assembler.Intel64.MachO.Packer
  alias Assembler.Intel64.Register
  alias Assembler.Intel64.Label

  @doc false
  def build(instructions) do
    instructions
    |> group_sections()
    |> encode_instructions()
    |> calculate_layout()
  end

  @init_sections %{".text" => [], ".data" => [], "extern" => [], "global" => [], "current" => nil}
  @doc false
  defp group_sections(asm_array) do
    asm_array
    |> Enum.reduce(@init_sections, fn
      [:global, name], sections ->
        Map.put(sections, "global", Map.fetch!(sections, "global") ++ [name])

      [:extern, label], sections ->
        Map.put(sections, "extern", Map.fetch!(sections, "extern") ++ [struct(Label, [section: :extern, name: label])])

      [:section, section], sections ->
        Map.put(sections, "current", section)

      instruction, %{"current" => ".text"} = sections ->
        Map.put(sections, ".text", sections[".text"] ++ [parse_text_section(instruction)])

      data, %{"current" => ".data"} = sections ->
        Map.put(sections, ".data", sections[".data"] ++ [parse_data_section(data)])
    end)
  end

  defp calculate_layout(%{".text" => text, ".data" => data} = layout) do
    # Calculate label offsets in .text
    {text, _last_offset} =
    Enum.reduce(text, {[], 0}, fn
      instruction, {instructions, offset} ->
        {
          instructions ++ [struct(instruction, [section_offset: offset])],
          offset + byte_size(instruction.data)
        }
    end)

    # Calculate label offsets in .data
    {data, _last_offset} =
    Enum.reduce(data, {[], 0}, fn
      instruction, {instructions, offset} ->
        {
          instructions ++ [struct(instruction, [section_offset: offset])],
          offset + byte_size(instruction.data)
        }
    end)

    data_binary = Enum.reduce(data, <<>>, &(&2 <> &1.data))
    text_binary = Enum.reduce(text, <<>>, &(&2 <> &1.data))

    layout
    |> Map.put(".text", text)
    |> Map.put(".data", data)
    |> Map.put(".text_binary", text_binary)
    |> Map.put(".data_binary", data_binary)
  end

  defp encode_instructions(%{".text" => text_section} = layout) do
    Enum.map(text_section, fn
      struct when is_struct(struct) ->
        struct

      instruction when is_list(instruction) ->
        encode_instruction(instruction)

      instruction when is_atom(instruction) ->
        encode_instruction([instruction])
    end)
    |> then(&Map.put(layout, ".text", &1))
  end

  defp encode_instruction([instruction | params]) do
    instruction
    |> Atom.to_string()
    |> String.upcase()
    |> (&Module.concat(Assembler.Intel64.Instruction, &1)).()
    |> then(&(struct(&1, [parameters: params])))
    |> then(&(struct(&1, [data: construct(&1)])))
  end

  defp parse_text_section([single]) do
    label = Atom.to_string(single)
    size = byte_size(label) - 1

    case label do
      <<label::binary-size(^size), ?:>> ->
        Label.create(:text, label)

      _ ->
        single
    end
  end

  defp parse_text_section(line) do
    line
    |> Enum.map(&(Register.create(&1)))
    |> Enum.map(&(parse_number(&1)))
  end

  _parse_data_section = """
  _parse_data_section will convert the defined data into a
  binary array. Converting text inside "..." and numbers
  [0-255]
  """
  defp parse_data_section([label, "db" | rest] = line) do
    label = Atom.to_string(label)
    size = byte_size(label) - 1

    case label do
      <<label::binary-size(^size), ?:>> ->
        Regex.split(~r/("[^"]+")/, Enum.join(rest, " "), include_captures: true)
        |> Enum.map(fn part ->
          if String.starts_with?(part, "\"") and String.ends_with?(part, "\"") do
            String.slice(part, 1..-2//1)
          else
            String.split(part, ",")
          end
        end)
        |> List.flatten()
        |> Enum.filter(&(&1 != <<>>))
        |> Enum.map(&(parse_number(String.trim(&1))))
        |> Enum.reduce(<<>>, fn
          str, acc when is_binary(str) ->
            acc <> :erlang.list_to_binary(String.to_charlist(str))

          num, acc when is_number(num) ->
            # This will cap at 255 (db)
            acc <> <<num>>
        end)
        |> then(fn binary_data ->
          Label.create(:data, label, binary_data)
        end)

      _ ->
        throw "Not supported operation: #{Enum.join(line)}"
    end
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
end
