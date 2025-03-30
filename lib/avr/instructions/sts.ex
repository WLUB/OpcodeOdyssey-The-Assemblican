defmodule Assembler.AVR.Instructions.STS do
  @moduledoc """
  Store Direct to Data Space
  Stores one byte from a Register to the data space.

  Cycles  2
  Words   2 (4 bytes)

  """
  use Assembler.Avr.Instructions.Base,
  size: 4,
  construct: fn
    %STS{parameters: [d, k]} ->
      {
        (0b1001 <<< 12) ||| (0b0011 <<< 8) ||| (_d(d) <<< 4),
        k &&& 0xffff
      }
  end,
  deconstruct: fn
    [opcode1, opcode2 | rest]
    when (opcode1>>>12) == (0b1001)
    and  (opcode1>>>8 ) == (0b0011)
    ->   {"sts #{opcode2} r#{opcode1 &&& 0x00FF}\n", rest}
  end
end
