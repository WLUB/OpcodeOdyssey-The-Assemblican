defmodule Assembler.Intel64.Instruction.LEA do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn
    %LEA {parameters: [%Register{reg: reg, size: 64}, mem_operand]} ->
      modrm = (reg <<< 3) ||| 5
      <<0x48, 0x8D, modrm, mem_operand :: little-unsigned-integer-size(32)>>
  end,
  deconstruct: fn
    nil -> nil
  end
end
