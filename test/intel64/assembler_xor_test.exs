defmodule Assembler.Intel64.AssemblerXorTest do
    use ExUnit.Case
    doctest Assembler
    alias Assembler.Intel64.Build

    test "xor eax edi" do
      """
      section .text
      xor eax edi
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x31, 0xF8>>)
      end)
    end

    test "xor r8d r15d" do
      """
      section .text
      xor r8d r15d
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x45, 0x31, 0xF8>>)
      end)
    end

    test "xor eax r15d" do
      """
      section .text
      xor eax r15d
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x44, 0x31, 0xF8>>)
      end)
    end

    test "xor r15d eax" do
      """
      section .text
      xor r15d eax
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x41, 0x31, 0xC7>>)
      end)
    end

    test "xor 4 64 reg" do
      """
      section .text
      xor rax rdi
      xor r8 r15
      xor rax r15
      xor r15 rax
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0x31, 0xF8, 0x4D, 0x31, 0xF8, 0x4C, 0x31, 0xF8, 0x49, 0x31, 0xC7>>)
      end)
    end
  end
