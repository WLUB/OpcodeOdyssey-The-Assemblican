defmodule Assembler.Intel64.Instruction.MOV do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn
    %MOV{parameters: [%Register{name: name, reg: reg, size: 32}, imm32]} when reg >= 0 and reg < 8 ->
      if imm32 > 0xFFFFFFFF, do: IO.puts("\n[Warning] The immediate value can't fit in the register and will be clipped.\n * mov #{name} #{imm32}\n           ^^^ #{imm32} > #{0xFFFFFFFF}")

      register_opcode = 0xB8 + reg
      <<register_opcode, imm32 :: little-unsigned-integer-size(32)>>

    %MOV{parameters: [%Register{name: name, reg: reg, size: 32}, imm32]} when reg >= 8 and reg < 16 ->
      if imm32 > 0xFFFFFFFF, do: IO.puts("\n[Warning] The immediate value can't fit in the register and will be clipped.\n * mov #{name} #{imm32}\n           ^^^ #{imm32} > #{0xFFFFFFFF}")

      register_opcode = 0xB8 + (reg - 8)
      <<0x41, register_opcode, imm32 :: little-unsigned-integer-size(32)>>

    %MOV{parameters: [%Register{name: name, reg: reg, size: 64}, imm64]} when reg >= 0 and reg < 8 ->
      # We could convert it into a 32-bit but maybe
      # better to let the user have complete control
      if imm64 <= 0xFFFFFFFF, do: IO.puts("\n[Info] You should use 32-bit register instead of 64-bit\n * mov #{name} #{imm64}\n           ^^^ #{imm64} <= #{0xFFFFFFFF}")
      if imm64 >  0xFFFFFFFFFFFFFFFF, do: IO.puts("\n[Warning] The immediate value can't fit in the register and will be clipped.\n * mov #{name} #{imm64}\n           ^^^ #{imm64} > #{0xFFFFFFFFFFFFFFFF}")

      register_opcode = 0xB8 + reg
      <<0x48, register_opcode, imm64 :: little-unsigned-integer-size(64)>>

    %MOV{parameters: [%Register{name: name, reg: reg, size: 64}, imm64]} when reg >= 8 and reg < 16 ->
      # We could convert it into a 32-bit but maybe
      # better to let the user have complete control
      if imm64 <= 0xFFFFFFFF, do: IO.puts("\n[Info] You should use 32-bit register instead of 64-bit\n * mov #{name} #{imm64}\n           ^^^ #{imm64} <= #{0xFFFFFFFF}")
      if imm64 >  0xFFFFFFFFFFFFFFFF, do: IO.puts("\n[Warning] The immediate value can't fit in the register and will be clipped.\n * mov #{name} #{imm64}\n           ^^^ #{imm64} > #{0xFFFFFFFFFFFFFFFF}")

      register_opcode = 0xB8 + (reg - 8)
      <<0x49, register_opcode, imm64 :: little-unsigned-integer-size(64)>>
  end,
  deconstruct: fn
    nil -> nil
  end
end
