defmodule Assembler do
  @moduledoc false
  alias Assembler.AVR.FileManger
  alias Assembler.AVR.Build
  alias Assembler.AVR.Decoder

  @doc false
  def main(["avr", "hex", file]) when is_binary(file) do
    file
    |> FileManger.read_file()
    |> Build.text_to_instructions()
    |> Build.encode_instruction()
    |> Build.generate_hex()
    |> FileManger.convert_to_output(file)
  end

  def main(["avr", "hex", "dis", file]) when is_binary(file) do
    file
    |> FileManger.read_file()
    |> String.trim()
    |> String.replace("\r", <<>>)
    |> String.split("\n")
    |> Decoder.decode()
    |> IO.puts()
  end

  def main([_ | _]) do
    IO.puts("Only AVR supported")
  end

  def main(_) do
    IO.puts("+----------- Assembler -----------------+")
    IO.puts("| Usage: ./assembler avr hex <file>     |")
    IO.puts("+--------- Disassembler ----------------+")
    IO.puts("| Usage: ./assembler avr hex dis <file> |")
    IO.puts("+---------------------------------------+")
  end
end
