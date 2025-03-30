defmodule Assembler.AVR.FileManger do
  @moduledoc false

  alias Assembler.AVR.PreCompiler
  alias Assembler.Utility

  @doc false
  def read_file(path) when is_binary(path) do
    case File.read(path) do
      {:ok, data} -> data
      {:error, _} -> Utility.exit_msg("Can't find file: #{path}")
    end
  end

  @doc false
  def write_file(path, content)
  when is_binary(path) and is_binary(content) do
    case File.write(path, content) do
      :ok         -> :ok
      {:error, _} -> Utility.exit_msg("Can't write file: #{path}")
    end
  end

  @doc """
  Convert hex instructions into a .hex file.
  We use the same name as the input name and replace
  type with .hex
  """
  def convert_to_output(instructions, file) when
  is_list(instructions) and is_binary(file) do
    [name | _exs] = String.split(file, ".")
    instructions
    |> Enum.reduce(<<>>, &("#{&2}\n#{&1}"))
    |> case do
      <<"\n", data::binary>> -> write_file("#{name}.hex", data)
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
    |> PreCompiler.pre_compile()
    |> Stream.map(fn [a | b] -> [String.to_atom(a) | b] end)
    |> Enum.map(fn [a | b] -> [a | parse_params(b)] end)
  end

  _parse_params = """
  Converting params into integers.
  """
  defp parse_params(params) when is_list(params) do
    Enum.map(params, fn
      v when is_number(v) -> v
      <<"0x", v::binary>> -> String.to_integer(v, 16)
      <<"0b", v::binary>> -> String.to_integer(v,  2)
      <<"r",  v::binary>> -> String.to_integer(v)
      v when is_binary(v) -> String.to_integer(v)
    end)
  end
end
