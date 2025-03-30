defmodule Assembler.AVR.DecoderTest do
  use ExUnit.Case
  doctest Assembler

  alias Assembler.AVR.Decoder

  test "ret" do
    [":02000000089561"]
    |> Decoder.decode()
    |> assert("ret\n")
  end

  test "ldi r16, 0x10" do
    [":0200000000E11D"]
    |> Decoder.decode()
    |> assert("ldi r16 16\n")
  end

  test "ldi r16 -> 0xff, 0x4a, 0x03" do
    [":060000000FEF0AE403E02B"]
    |> Decoder.decode()
    |> assert("ldi r16 255\nldi r16 74\nldi r16 3\n")
  end

  test "ldi r16-18, 0x10" do
    [":0600000000E110E120E127"]
    |> Decoder.decode()
    |> assert("ldi r16 16\nldi r17 16\nldi r18 16\n")
  end

  test "rjmp decode" do
    [":0800000001E002E003E0FCCF87", ":00000001FF"]
    |> Decoder.decode()
    |>  assert("ldi r16 1\nldi r16 2\nldi r16 3\nrjmp -4\n")
  end

  test "rcall decode" do
    [":0800000001E002E003E0FCDF77", ":00000001FF"]
    |> Decoder.decode()
    |>  assert("ldi r16 1\nldi r16 2\nldi r16 3\nrjmp -4\n")
  end
end
