defmodule Assembler.Intel64.Register do
  alias Assembler.Intel64.Register
  @enforce_keys [:reg, :size]
  defstruct [:reg, :size]

  @doc """
  create/1 will convert the name into a register
  if the name matches with a known register,
  otherwise we return the name.
  """
  def create(name) when is_binary(name) do
    case name do
      "rax" -> %Register{reg:  0, size: 64}
      "rcx" -> %Register{reg:  1, size: 64}
      "rdx" -> %Register{reg:  2, size: 64}
      "rbx" -> %Register{reg:  3, size: 64}
      "rsp" -> %Register{reg:  4, size: 64}
      "rbp" -> %Register{reg:  5, size: 64}
      "rsi" -> %Register{reg:  6, size: 64}
      "rdi" -> %Register{reg:  7, size: 64}
      "r8"  -> %Register{reg:  8, size: 64}
      "r9"  -> %Register{reg:  9, size: 64}
      "r10" -> %Register{reg: 10, size: 64}
      "r11" -> %Register{reg: 11, size: 64}
      "r12" -> %Register{reg: 12, size: 64}
      "r13" -> %Register{reg: 13, size: 64}
      "r14" -> %Register{reg: 14, size: 64}
      "r15" -> %Register{reg: 15, size: 64}
      _no_  -> name
    end
  end

  def create(name), do: name
end
