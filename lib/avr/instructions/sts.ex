defmodule Assembler.AVR.Instruction.STS do
  @moduledoc """
  Store Direct to Data Space
  Stores one byte from a Register to the data space.

  Cycles  2
  Words   2 (4 bytes)

  """
  use Assembler.AVR.Instruction,
  size: 4,
  construct: fn
    %STS{parameters: [k, d]} ->
      {
        ((0b1001 <<< 12) ||| (0b001 <<< 9) ||| (((d >>> 4) &&& 0x1) <<< 8) ||| ((d &&& 0xF) <<< 4)),
        k &&& 0xFFFF
      }
  end,
  deconstruct: fn
    [opcode1, opcode2 | rest]
    when
    (opcode1 &&& 0xF000) == 0x9000 and
    (opcode1 &&& 0x0E00) == 0x0200 and
    (opcode1 &&& 0x000F) == 0x0000 ->
      reg = (opcode1 &&& 0x01F0) >>> 4
      {"sts #{opcode2} r#{reg}\n", rest}
  end
end
