defmodule Assembler.Intel64.FileManger do
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

  @doc false
  def convert_to_output(data, output_name \\ "output.o") do
    File.write!(output_name, data)
  end
end
