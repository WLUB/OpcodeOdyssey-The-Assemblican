defmodule Assembler.AVR.PreCompiler do
  @moduledoc false

  @doc false
  def set_constants() do
    nil
    # Read and set all constant values
  end

  @state %{index: 0, refs: %{}, instructions: []}
  @doc false
  def pre_compile(instructions) when is_list(instructions) do
    # Find all refs
    Enum.reduce(instructions, @state, fn [o | p] = _ins, acc ->
      case String.reverse(o) do
        <<":", rest::binary>> ->
          %{
            index: acc.index,
            refs: Map.put(acc.refs, String.reverse(rest), acc.index),
            instructions: acc.instructions
          }
        _ ->
          %{
            index: acc.index + 1,
            refs: acc.refs,
            instructions: acc.instructions ++ [[o | p]]
          }
      end
    end)
    |> case do
      d ->
        # Calculate distance to jump
        Enum.reduce(d.instructions,
        %{index: 0, refs: d.refs, instructions: []},
        fn
        ["rjmp", ref], acc  ->
          %{
            index: acc.index + 1,
            refs: acc.refs,                   # Should prob be checked
            instructions: acc.instructions ++ [["rjmp", acc.refs[ref] - acc.index - 1]]
          }
        ["rcall", ref], acc ->
          %{
            index: acc.index + 1,
            refs: acc.refs,                   # Should prob be checked
            instructions: acc.instructions ++ [["rcall", acc.refs[ref] - acc.index - 1]]
          }
        i, acc ->
          %{
            index: acc.index + 1,
            refs: acc.refs,
            instructions: acc.instructions ++ [i]
          }
        end)
        |> case do
          x -> x.instructions
        end
    end
  end
end
