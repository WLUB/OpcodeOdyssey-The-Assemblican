defmodule Assembler.Intel64.AssemblerMovTest do
    use ExUnit.Case
    doctest Assembler
    alias Assembler.Intel64.Build

    ###############
    # 64-bit test #
    ###############


    test "mov reg0 imm64" do
      """
      section .text
      mov rax 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x48, 0xB8, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg1 imm64" do
      """
      section .text
      mov rcx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x48, 0xB9, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg2 imm64" do
      """
      section .text
      mov rdx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x48, 0xBA, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg3 imm64" do
      """
      section .text
      mov rbx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x48, 0xBB, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg4 imm64" do
      """
      section .text
      mov rsp 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x48, 0xBC, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg5 imm64" do
      """
      section .text
      mov rbp 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x48, 0xBD, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg6 imm64" do
      """
      section .text
      mov rsi 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x48, 0xBE, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg7 imm64" do
      """
      section .text
      mov rdi 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x48, 0xBF, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg8 imm64" do
      """
      section .text
      mov r8 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x49, 0xB8, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg9 imm64" do
      """
      section .text
      mov r9 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x49, 0xB9, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg10 imm64" do
      """
      section .text
      mov r10 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x49, 0xBA, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg11 imm64" do
      """
      section .text
      mov r11 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x49, 0xBB, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg12 imm64" do
      """
      section .text
      mov r12 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x49, 0xBC, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg13 imm64" do
      """
      section .text
      mov r13 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x49, 0xBD, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg14 imm64" do
      """
      section .text
      mov r14 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x49, 0xBE, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    test "mov reg15 imm64" do
      """
      section .text
      mov r15 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x49, 0xBF, 10, 0, 0, 0, 0, 0, 0, 0>>)
      end)
    end

    ###############
    # 32-bit test #
    ###############


    test "mov reg0 imm32" do
      """
      section .text
      mov eax 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0xB8, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg1 imm32" do
      """
      section .text
      mov ecx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0xB9, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg2 imm32" do
      """
      section .text
      mov edx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0xBA, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg3 imm32" do
      """
      section .text
      mov ebx 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0xBB, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg4 imm32" do
      """
      section .text
      mov esp 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0xBC, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg5 imm32" do
      """
      section .text
      mov ebp 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0xBD, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg6 imm32" do
      """
      section .text
      mov esi 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0xBE, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg7 imm32" do
      """
      section .text
      mov edi 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0xBF, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg8 imm32" do
      """
      section .text
      mov r8d 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x41, 0xB8, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg9 imm32" do
      """
      section .text
      mov r9d 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x41, 0xB9, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg10 imm32" do
      """
      section .text
      mov r10d 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x41, 0xBA, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg11 imm32" do
      """
      section .text
      mov r11d 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x41, 0xBB, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg12 imm32" do
      """
      section .text
      mov r12d 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x41, 0xBC, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg13 imm32" do
      """
      section .text
      mov r13d 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x41, 0xBD, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg14 imm32" do
      """
      section .text
      mov r14d 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x41, 0xBE, 10, 0, 0, 0>>)
      end)
    end

    test "mov reg15 imm32" do
      """
      section .text
      mov r15d 10
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => [ins]} = _ ->
        assert(ins.data == <<0x41, 0xBF, 10, 0, 0, 0>>)
      end)
    end
  end
