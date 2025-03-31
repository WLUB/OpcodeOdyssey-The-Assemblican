defmodule Assembler.AVR.FileManger do
  @moduledoc false

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
end
