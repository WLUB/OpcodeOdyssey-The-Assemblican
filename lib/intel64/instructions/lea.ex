defmodule Assembler.Intel64.Instruction.LEA do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn
    %LEA {parameters: [%Register{reg: reg, size: 64}, <<"#", _label::binary>>]} when reg >= 0 and reg < 8 ->
      modrm = (reg <<< 3) ||| 5
      <<0x48, 0x8D, modrm, 0 :: little-unsigned-integer-size(32)>>

    %LEA {parameters: [%Register{reg: reg, size: 64}, mem_operand]} when reg >= 0 and reg < 8 ->
      modrm = (reg <<< 3) ||| 5
      <<0x48, 0x8D, modrm, mem_operand :: little-unsigned-integer-size(32)>>

    %LEA {parameters: [%Register{reg: reg, size: 64}, mem_operand]} when reg >= 8 and reg < 16 ->
      modrm = ((reg - 8) <<< 3) ||| 5
      <<0x4C, 0x8D, modrm, mem_operand :: little-unsigned-integer-size(32)>>
  end,
  deconstruct: fn
    nil -> nil
  end
end
