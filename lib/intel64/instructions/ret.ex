defmodule Assembler.Intel64.Instruction.RET do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn
    %RET{} = _ ->
      <<0xC3>>
  end,
  deconstruct: fn
    nil -> nil
  end
end
