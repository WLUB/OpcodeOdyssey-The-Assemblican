defmodule Assembler do
  @moduledoc false
  alias Assembler.AVR
  alias Assembler.Intel64

  @doc false
  def main(["avr", "hex", file]) when is_binary(file) do
    file
    |> AVR.FileManger.read_file()
    |> AVR.Build.text_to_instructions()
    |> AVR.Build.encode_instruction()
    |> AVR.Build.generate_hex()
    |> AVR.FileManger.convert_to_output(file)
  end

  def main(["avr", "hex", "dis", file]) when is_binary(file) do
    file
    |> AVR.FileManger.read_file()
    |> String.trim()
    |> String.replace("\r", <<>>)
    |> String.split("\n")
    |> AVR.Decoder.decode()
    |> IO.puts()
  end

  def main(["x64", "mac", file]) when is_binary(file) do
    file
    |> Intel64.FileManger.read_file()
    |> Intel64.Build.text_to_instructions()
    |> Intel64.Build.build()
    |> Intel64.Build.pack({:mach_o, :object})
    |> Intel64.FileManger.convert_to_output("output.o")
  end

  def main(["x64", "mac", file, output]) when is_binary(file) do
    file
    |> Intel64.FileManger.read_file()
    |> Intel64.Build.text_to_instructions()
    |> Intel64.Build.build()
    |> Intel64.Build.pack({:mach_o, :object})
    |> Intel64.FileManger.convert_to_output(output)
  end

  def main(_) do
    IO.puts("+----------- Assembler ----------------------+")
    IO.puts("| Usage: ./assembler avr hex <file>          |")
    IO.puts("| Usage: ./assembler x64 mac <file>          |")
    IO.puts("| Usage: ./assembler x64 mac <file> <output> |")
    IO.puts("+--------- Disassembler ---------------------+")
    IO.puts("| Usage: ./assembler avr hex dis <file>      |")
    IO.puts("+--------------------------------------------+")
  end
end
