defmodule Assembler.AVR.Instruction.Builder do
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
          def construct(%unquote(module){} = instruction) do
            case instruction do
              unquote(construct_clauses)
            end
            |> case do
              res when is_tuple(res) -> res
              res -> {res, nil}
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
    modules
    |> Enum.map(fn module ->
      module.get_deconstruct()
    end)
    |> Enum.reduce([], fn {:fn, _meta, deconstruct_clauses}, acc ->
      deconstruct_clauses ++ acc
    end)
    |> then(fn deconstruct_clauses ->
        quote do
          import Bitwise
          def deconstruct(opcodes, asm \\ <<>>) when is_list(opcodes) and is_binary(asm) do
            case opcodes do
              unquote(
              deconstruct_clauses ++
              quote do
                [-257 | rest] -> # EOF
                  {<<>>, rest}
                [opcode | rest] ->
                  IO.puts("[Error] Can't decode: #{opcode}")
                  {"; Unknown instruction (#{opcode})\n", rest}
              end)
            end
            |> case do
              {text, []}   -> asm <> text
              {text, rest} -> deconstruct(rest, asm <> text)
            end
          end
        end
    end)
  end

  @doc false
  defmacro __using__(modules) do

    {expanded_module, constructor, decoder} = modules
    |> Enum.map(&Macro.expand(&1, __CALLER__))
    |> then(&{&1, generate_constructor(&1), generate_decoder(&1)})

    alias_modules = Enum.map(expanded_module, fn mod -> quote do: alias unquote(mod) end)

    quote do
      unquote_splicing(alias_modules)
      @before_compile unquote(__MODULE__)
      unquote_splicing(constructor)
      unquote(decoder)
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
