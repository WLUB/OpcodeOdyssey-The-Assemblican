defmodule Assembler.Intel64.Instruction.XOR do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn
   %XOR{
      parameters: [
        %Register{reg: reg1, size: 32},
        %Register{reg: reg2, size: 32}
      ]
    } when reg1 >= 0 and reg1 < 8 and reg2 >= 0 and reg2 < 8 ->
      modrm = 0xC0 ||| (reg2 <<< 3) ||| reg1
      <<0x31, modrm>>

    %XOR{
      parameters: [
        %Register{reg: reg1, size: size1},
        %Register{reg: reg2, size: size2}
      ]
    } when reg1 >= 0 and reg1 < 16 and reg2 >= 0 and reg2 < 16 and size1 == size2 ->

      prefix =
      0x40
      ||| if(reg1  >  7, do: 0x01, else: 0x00)
      ||| if(reg2  >  7, do: 0x04, else: 0x00)
      ||| if(size2 > 32, do: 0x08, else: 0x00)

      modrm =
      0xC0
      ||| (if(reg2 > 7, do: reg2 - 8, else: reg2) <<< 3)
      |||  if(reg1 > 7, do: reg1 - 8, else: reg1)

      <<prefix, 0x31, modrm>>

  end,
  deconstruct: fn
    nil -> nil
  end
end
