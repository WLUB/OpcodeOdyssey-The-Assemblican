defmodule Assembler.AVR.Instruction.RCALL do
  @moduledoc """
  Relative Call to Subroutine
  Relative call to an address within PC - 2K + 1 and PC + 2K (words).

  Cycles          3 devices with 16-bit PC 4 devices with 22-bit PC
  Cycles XMEGA    2 devices with 16-bit PC 3 devices with 22-bit PC
  Words           1 (2 bytes)

  """
  use Assembler.AVR.Instruction,
    size: 2,
    construct: fn
      %RCALL{parameters: [k], address: address} when rem(2*k - address, 2) != 0 ->
        raise "Odd address operand, must be word-aligned"

      %RCALL{parameters: [k]} when k < -2048 or k > 2047 ->
        raise "Relative address out of range: must be between -2048 and 2047"

      %RCALL{parameters: [k], address: address} ->
        (0b1101 <<< 12) ||| (div(2*k - address, 2) &&& 0x0FFF)
    end,
    deconstruct: fn
      [opcode | rest] when (opcode >>> 12) == (0b1101) ->
        {"rcall #{_sign(opcode &&& 0x0FFF)}\n", rest}
    end
end
