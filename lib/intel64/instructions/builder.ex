defmodule Assembler.Intel64.Instruction.Builder do
  @moduledoc """
  A helper function to get access to all the instructions
  """

  _generate_constructor = """
  `generate_constructor` will generate `construct/1` which will parse
  the ASM instruction into byte code with the instructions `construct` method.

  One `construct/1` will be generate per instruction module.
  """
  defp generate_constructor(modules) when is_list(modules) do
    modules
    |> Enum.map(fn module ->
      {module, module.get_construct()}
    end)
    |> Enum.map(fn {module, {:fn, _meta, construct_clauses}} ->
        quote do
          import Bitwise
          alias Assembler.Intel64.Register
          def construct(%unquote(module){} = instruction) do
            case instruction do
              unquote(construct_clauses)
            end
          end
        end
    end)
  end

  _generate_decoder = """
  `generate_decoder` will generate `deconstruct/2` which will parse
  the opcodes into ASM text with the instructions deconstruct methods.
  """
  defp generate_decoder(modules) when is_list(modules) do
    nil
  end

  @doc false
  defmacro __using__(modules) do

    {expanded_module, constructor, _decoder} = modules
    |> Enum.map(&Macro.expand(&1, __CALLER__))
    |> then(&{&1, generate_constructor(&1), generate_decoder(&1)})

    alias_modules = Enum.map(expanded_module, fn mod -> quote do: alias unquote(mod) end)

    quote do
      unquote_splicing(alias_modules)
      @before_compile unquote(__MODULE__)
      unquote_splicing(constructor)
      # unquote(decoder)
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def _sign(v) when v > 2047, do:  v - 0x1000
      def _sign(v), do: v
      def _d2r(d), do: d + 16
      def _d(d), do: d - 16
    end
  end
end
