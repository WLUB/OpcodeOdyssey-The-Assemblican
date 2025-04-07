defmodule Assembler.Intel64.Instruction.INT do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn
    %INT{parameters: []} ->
      # Interrupts on overflow.
      <<0xCE>>

    %INT{parameters: [imm8]} when imm8 == 0x03->
      # macro for 0xCD 0x03
      <<0xCC>>

    %INT{parameters: [imm8]} when imm8 >= 0x00 and imm8 <= 0xFF->
      <<0xCD, imm8 :: little-unsigned-integer-size(8)>>

    %INT{} = _ ->
      raise "Invalid definition for int"
  end,
  deconstruct: fn
    nil -> nil
  end
end
