defmodule Assembler.Intel64.Instruction.CALL do
  @moduledoc """

  """
  use Assembler.Intel64.Instruction,
  construct: fn

    %CALL{parameters: [_]} = _ ->
      # Only supporting relative linking, so
      # we don't care about the address here
      <<0xE8, 0, 0, 0, 0>>
  end,
  deconstruct: fn
    nil -> nil
  end
end
