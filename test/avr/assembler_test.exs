defmodule Assembler.AVR.AssemblerTest do
    use ExUnit.Case
    doctest Assembler
    alias Assembler.AVR.Build

    test "rjmp test" do
      [
        [:ldi,   16, 1],
        [:ldi,   16, 2],
        [:ldi,   16, 3],
        [:rjmp,  -4   ],
      ]
      |> Build.encode_instruction()
      |> Build.generate_hex()
      |> case do
        [":0800000001E002E003E0FCCF87", ":00000001FF"] -> assert(true)
        _ -> assert(false)
      end
    end

    test "rcall test" do
      [
        [:ldi,   16, 1],
        [:ldi,   16, 2],
        [:ldi,   16, 3],
        [:rcall,  -4   ],
      ]
      |> Build.encode_instruction()
      |> Build.generate_hex()
      |> case do
        [":0800000001E002E003E0FCDF77", ":00000001FF"] -> assert(true)
        _ -> assert(false)
      end
    end

    test "ret" do
      [
        [:ret            ]
      ]
      |> Build.encode_instruction()
      |> Build.generate_hex()
      |> case do
        [":02000000089561", ":00000001FF"] -> assert(true)
        _ -> assert(false)
      end
    end

    test "ldi r16, 0x10" do
      [
        [:ldi,   16, 0x10]
      ]
      |> Build.encode_instruction()
      |> Build.generate_hex()
      |> case do
        [":0200000000E11D", ":00000001FF"] -> assert(true)
        _ -> assert(false)
      end
    end

    test "ldi r16 -> 0xff, 0x4a, 0x03" do
      [
        [:ldi,   16, 0xff],
        [:ldi,   16, 0x4a],
        [:ldi,   16, 0x03]
      ]
      |> Build.encode_instruction()
      |> Build.generate_hex()
      |> case do
        [":060000000FEF0AE403E02B", ":00000001FF"] -> assert(true)
        _ -> assert(false)
      end
    end

    test "ldi r16-18, 0x10" do
      [
        [:ldi,   16, 0x10],
        [:ldi,   17, 0x10],
        [:ldi,   18, 0x10]
      ]
      |> Build.encode_instruction()
      |> Build.generate_hex()
      |> case do
        [":0600000000E110E120E127", ":00000001FF"] -> assert(true)
        _ -> assert(false)
      end
    end

  end
