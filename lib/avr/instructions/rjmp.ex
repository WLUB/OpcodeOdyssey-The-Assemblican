defmodule Assembler.AVR.Instructions.RJMP do
  @moduledoc """
  Relative Jump
  Relative jump to an address within PC - 2K + 1 and PC + 2K (words)

  Cycles  1
  Words   1 (2 bytes)

  """
  use Assembler.Avr.Instructions.Base,
  size: 2,
  construct: fn
    %RJMP{parameters: [k]} when k < -2048 or k > 2047 ->
      raise "Relative address out of range: must be between -2048 and 2047"

    %RJMP{parameters: [k], address: address} ->
      (0b1100 <<< 12) ||| ((k) &&& 0x0FFF)
  end,
  deconstruct: fn
    [opcode | rest] when (opcode>>>12) == (0b1100) ->
      {"rjmp #{_sign(opcode &&& 0x0FFF) }\n", rest}
  end
end
