defmodule Assembler.Intel64.AssemblerMovTest do
    use ExUnit.Case
    doctest Assembler
    alias Assembler.Intel64.Build

    test "mov reg0 imm64" do
      """
      section .text
      mov rax 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0xB8, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg1 imm64" do
      """
      section .text
      mov rcx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0xB9, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg2 imm64" do
      """
      section .text
      mov rdx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0xBA, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg3 imm64" do
      """
      section .text
      mov rbx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0xBB, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg4 imm64" do
      """
      section .text
      mov rsp 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0xBC, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg5 imm64" do
      """
      section .text
      mov rbp 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0xBD, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg6 imm64" do
      """
      section .text
      mov rsi 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0xBE, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg7 imm64" do
      """
      section .text
      mov rdi 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x48, 0xBF, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg8 imm64" do
      """
      section .text
      mov r8 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x49, 0xB8, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg9 imm64" do
      """
      section .text
      mov r9 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x49, 0xB9, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg10 imm64" do
      """
      section .text
      mov r10 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x49, 0xBA, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg11 imm64" do
      """
      section .text
      mov r11 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x49, 0xBB, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg12 imm64" do
      """
      section .text
      mov r12 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x49, 0xBC, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg13 imm64" do
      """
      section .text
      mov r13 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x49, 0xBD, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg14 imm64" do
      """
      section .text
      mov r14 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x49, 0xBE, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg15 imm64" do
      """
      section .text
      mov r15 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0x49, 0xBF, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end
  end
