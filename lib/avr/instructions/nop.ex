defmodule Assembler.AVR.Instruction.NOP do
  @moduledoc """
  No Operation

  Cycles  1
  Words   1 (2 bytes)

  """
  use Assembler.AVR.Instruction,
  size: 2,
  construct: fn
    %NOP{} = _ -> 0b0000000000000000
  end,
  deconstruct: fn
    [opcode | rest] when opcode == 0b0000000000000000 ->
      {"nop\n", rest}
  end
end
