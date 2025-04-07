defmodule Assembler.Intel64.Instruction do
  defmacro __using__(opts) do
    construct   = Macro.escape(Keyword.fetch!(opts, :construct))
    deconstruct = Macro.escape(Keyword.fetch!(opts, :deconstruct))

    quote do
      @enforce_keys [:address, :parameters]
      defstruct [
        address: 0,
        parameters: []
      ]

      def get_construct(), do: unquote(construct)
      def get_deconstruct(), do: unquote(deconstruct)
    end
  end
end
