defmodule Assembler.AVR.Instruction.RJMP do
  @moduledoc """
  Relative Jump
  Relative jump to an address within PC - 2K + 1 and PC + 2K (words)

  Cycles  2
  Words   1 (2 bytes)

  """
  use Assembler.AVR.Instruction,
  size: 2,
  construct: fn
    %RJMP{parameters: [k], address: address} when rem(2*k - address, 2) != 0 ->
      raise "Odd address operand, must be word-aligned"

    %RJMP{parameters: [k]} when k < -2048 or k > 2047 ->
      raise "Relative address out of range: must be between -2048 and 2047"

    %RJMP{parameters: [k], address: address} ->
      (0b1100 <<< 12) ||| (div(2*k - address, 2) &&& 0x0FFF)
  end,
  deconstruct: fn
    [opcode | rest] when (opcode>>>12) == (0b1100) ->
      {"rjmp #{_sign(opcode &&& 0x0FFF) }\n", rest}
  end
end
