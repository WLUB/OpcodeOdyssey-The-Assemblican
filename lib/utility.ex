defmodule Assembler.Utility do
  @moduledoc false

  @doc false
  def hex_format(v, p)
  when is_integer(v) and is_integer(p),
  do: Integer.to_string(v, 16) |> String.pad_leading(p, "0")

  @doc false
  def append(a, b)
  when is_binary(a) and is_binary(b),
  do: "#{a}#{b}"

  @doc false
  def append(a, b)
  when is_list(a) and is_list(b),
  do: a ++ b

  @doc false
  def split_hex(str) when is_binary(str),
  do: split_hex(str, [])

  defp split_hex(<<>>, acc),
  do: Enum.reverse(acc)

  defp split_hex(<<a::binary-size(2), rest::binary>>, acc),
  do: split_hex(rest, [a | acc])

  @doc false
  def flatten_list(a, acc \\ [])
  def flatten_list([], acc), do: acc
  def flatten_list([a | b], acc) when is_list(a),
  do: flatten_list(b, acc ++ a)


  def append_to_end(a, b)
  when is_list(a),
  do: a ++ [b]

  @doc false
  def exit_msg(msg) when is_binary(msg) do
    IO.puts(msg)
    System.halt(1)
  end
end
