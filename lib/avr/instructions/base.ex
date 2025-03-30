defmodule Assembler.Avr.Instructions.Base do
  defmacro __using__(opts) do

    # The instruction is atom is based on
    # the module name of the caller
    # We don't really need this when we are
    # converting each module into a struct
    instruction = __CALLER__.module
    |> Module.split()
    |> List.last()
    |> String.downcase()
    |> String.to_atom()

    construct   = Macro.escape(Keyword.fetch!(opts, :construct))
    deconstruct = Macro.escape(Keyword.fetch!(opts, :deconstruct))
    size        = Macro.escape(Keyword.fetch!(opts, :size))

    quote do
      @enforce_keys [:instruction, :address, :parameters, :size]
      defstruct [
        instruction: unquote(instruction),
        size: unquote(size),
        address: 0,
        parameters: []
      ]

      def get_construct(), do: unquote(construct)
      def get_deconstruct(), do: unquote(deconstruct)
    end
  end
end
