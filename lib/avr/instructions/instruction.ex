defmodule Assembler.AVR.Instruction do
  defmacro __using__(opts) do

    construct   = Macro.escape(Keyword.fetch!(opts, :construct))
    deconstruct = Macro.escape(Keyword.fetch!(opts, :deconstruct))
    size        = Macro.escape(Keyword.fetch!(opts, :size))

    quote do
      @enforce_keys [:address, :parameters, :size]
      defstruct [
        size: unquote(size),
        address: 0,
        parameters: []
      ]

      def get_construct(), do: unquote(construct)
      def get_deconstruct(), do: unquote(deconstruct)
    end
  end
end
