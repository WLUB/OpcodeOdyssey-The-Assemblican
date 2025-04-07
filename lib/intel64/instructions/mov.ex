defmodule Assembler.Intel64.Instruction.MOV do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn
    %MOV{parameters: [%Register{reg: reg, size: 64}, imm64]} when reg >= 0 and reg < 8 ->
      register_opcode = 0xB8 + reg
      <<0x48, register_opcode, imm64 :: little-unsigned-integer-size(64)>>

    %MOV{parameters: [%Register{reg: reg, size: 64}, imm64]} when reg >= 8 and reg < 16 ->
      register_opcode = 0xB8 + (reg - 8)
      <<0x49, register_opcode, imm64 :: little-unsigned-integer-size(64)>>
  end,
  deconstruct: fn
    nil -> nil
  end
end
