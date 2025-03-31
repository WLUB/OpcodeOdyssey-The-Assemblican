defmodule Assembler.AVR.Instruction.LDI do
  @moduledoc """
  Load Immediate
  Loads an 8-bit constant directly to register 16 to 31.

  Cycles  1
  Words   1 (2 bytes)

  """
  use Assembler.AVR.Instruction,
  size: 2,
  construct: fn
    %LDI{parameters: [d, _k]} when d < 16 or d > 31  ->
      raise "Invalid LDI register! Need to be in range 16-31"

    %LDI{parameters: [_d, k]} when k < 0 or k > 255 ->
      raise "Invalid LDI immediate! Need to be in range 0-255"

    %LDI{parameters: [d, k]} ->
      k_h = (k &&& 0xF0) >>> 4
      k_l = (k &&& 0x0F)
      (0b1110 <<< 12) ||| (k_h <<< 8) ||| (_d(d) <<< 4) ||| k_l
  end,
  deconstruct: fn
    [opcode | rest] when (opcode>>>12) == (0b1110) ->
      {"ldi r#{_d2r((opcode >>> 4)  &&& 0x000F)} #{((((opcode >>> 8)  &&& 0x000f) <<< 4) ||| (opcode &&& 0x000f))}\n", rest}
  end
end
