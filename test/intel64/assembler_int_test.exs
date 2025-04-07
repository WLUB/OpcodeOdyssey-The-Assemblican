defmodule Assembler.Intel64.AssemblerIntTest do
    use ExUnit.Case
    doctest Assembler
    alias Assembler.Intel64.Build

    test "int 0" do
      """
      section .text
      int 0
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0xCD, 0>>)
      end)
    end

    test "int 1" do
      """
      section .text
      int 1
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0xCD, 1>>)
      end)
    end

    test "int 2" do
      """
      section .text
      int 2
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0xCD, 2>>)
      end)
    end

    test "int 3" do
      """
      section .text
      int 3
      """
      |> Build.text_to_instructions()
      |> Build.build()
      |> then(fn %{".text" => data} = _ ->
        assert(data == <<0xCC>>)
      end)
    end

    test "int 4-255" do
      Enum.each(4..255, fn i ->
        """
        section .text
        int #{i}
        """
        |> Build.text_to_instructions()
        |> Build.build()
        |> then(fn %{".text" => data} = _ ->
          assert(data == <<0xCD, i>>)
        end)
      end)
    end
  end
