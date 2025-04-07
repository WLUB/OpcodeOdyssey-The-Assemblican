defmodule Assembler.Intel64.Instruction.SYSCALL do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn
    %SYSCALL{} = _ ->
      <<0x0F, 0x05>>
  end,
  deconstruct: fn
    nil -> nil
  end
end
