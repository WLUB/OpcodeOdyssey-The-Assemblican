defmodule Assembler.AVR.Instruction.RET do
  @moduledoc """
  Return from Subroutine

  Returns from subroutine. The return address is loaded from the STACK.
  The Stack Pointer uses a pre-increment scheme during RET.

  Cycles  4 devices with 16-bit PC 5 devices with 22-bit PC
  Words   1 (2 bytes)

  """
  use Assembler.AVR.Instruction,
  size: 2,
  construct: fn
    %RET{} = _ -> 0b1001010100001000
  end,
  deconstruct: fn
    [opcode | rest] when opcode == 0b1001010100001000 ->
      {"ret\n", rest}
  end
end
