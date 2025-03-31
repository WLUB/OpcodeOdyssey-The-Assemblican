defmodule Assembler.AVR.FlowTest do
  use ExUnit.Case
  doctest Assembler
  alias Assembler.AVR.Build
  alias Assembler.AVR.Decoder

  defp assert_eq(a, b) when is_binary(a) and is_binary(b) do
    assert(a == b)
  end

  test "rjmp 2" do
    asm = "rjmp 2\n"
    Build.text_to_instructions(asm)
    |> Build.encode_instruction()
    |> Build.generate_hex()
    |> Decoder.decode()
    |> assert_eq(asm)
  end

  test "rjmp -2" do
    asm = "rjmp -2\n"
    Build.text_to_instructions(asm)
    |> Build.encode_instruction()
    |> Build.generate_hex()
    |> Decoder.decode()
    |> assert_eq(asm)
  end

  test "sts 48" do
    asm = "sts 48 r17\n"
    Build.text_to_instructions(asm)
    |> Build.encode_instruction()
    |> Build.generate_hex()
    |> Decoder.decode()
    |> assert_eq(asm)
  end

  test "sts 0x30" do
    "sts 0x30 r17\n"
    |> Build.text_to_instructions()
    |> Build.encode_instruction()
    |> Build.generate_hex()
    |> Decoder.decode()
    |> assert_eq("sts 48 r17\n")
  end
end
