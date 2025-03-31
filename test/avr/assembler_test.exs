defmodule Assembler.AVR.AssemblerTest do
    use ExUnit.Case
    doctest Assembler
    alias Assembler.AVR.Build

    test "directive test - jump into later memory" do
      """
      .org 0x0002
      ldi r16 0x10
      rjmp jump
      .org 0x0010
      sts 0x30 r17
      jump:
      ldi r16 0x10
      """
      |> Build.text_to_instructions()
      |> Build.encode_instruction()
      |> Build.generate_hex()
      |> case do
        [
          ":10000000000000E107C00000000000000000000048",
          ":060010001093300000E136",
          ":00000001FF"
        ] -> assert(true)
        _ -> assert(false)
      end
    end

    test "directive test - call into later memory" do
      """
      .org 0x0002
      ldi r16 0x10
      rcall jump
      .org 0x0010
      sts 0x30 r17
      jump:
      ldi r16 0x10
      """
      |> Build.text_to_instructions()
      |> Build.encode_instruction()
      |> Build.generate_hex()
      |> case do
        [
          ":10000000000000E107D00000000000000000000038",
          ":060010001093300000E136",
          ":00000001FF"
        ] -> assert(true)
        _ -> assert(false)
      end
    end

    test "directive test - Same label" do
      assert_raise(RuntimeError, fn ->
        """
        .org 0x0001
        ldi r16 0x10
        rjmp jump
        .org 0x0010
        sts 0x30 r17
        jump:
        ldi r16 0x10
        jump:
        """
        |> Build.text_to_instructions()
        |> Build.encode_instruction()
        |> Build.generate_hex()
      end)
    end

    test "directive test - Miss aligned jump into later memory" do
      assert_raise(RuntimeError, fn ->
        """
        .org 0x0001
        ldi r16 0x10
        rjmp jump
        .org 0x0010
        sts 0x30 r17
        jump:
        ldi r16 0x10
        """
        |> Build.text_to_instructions()
        |> Build.encode_instruction()
        |> Build.generate_hex()
      end)
    end

    test "directive test - Miss aligned call into later memory" do
      assert_raise(RuntimeError, fn ->
        """
        .org 0x0001
        ldi r16 0x10
        rcall jump
        .org 0x0010
        sts 0x30 r17
        jump:
        ldi r16 0x10
        """
        |> Build.text_to_instructions()
        |> Build.encode_instruction()
        |> Build.generate_hex()
      end)
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
