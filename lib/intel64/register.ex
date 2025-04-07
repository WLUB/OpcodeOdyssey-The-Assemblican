defmodule Assembler.Intel64.Register do
  alias Assembler.Intel64.Register
  @enforce_keys [:name, :reg, :size]
  defstruct [:name, :reg, :size]

  @doc """
  create/1 will convert the name into a register
  if the name matches with a known register,
  otherwise we return the name.
  """
  def create(name) when is_binary(name) do
    case name do
      # 64-bit
      "rax" -> %Register{name: "rax", reg:  0, size: 64}
      "rcx" -> %Register{name: "rcx", reg:  1, size: 64}
      "rdx" -> %Register{name: "rdx", reg:  2, size: 64}
      "rbx" -> %Register{name: "rbx", reg:  3, size: 64}
      "rsp" -> %Register{name: "rsp", reg:  4, size: 64}
      "rbp" -> %Register{name: "rbp", reg:  5, size: 64}
      "rsi" -> %Register{name: "rsi", reg:  6, size: 64}
      "rdi" -> %Register{name: "rdi", reg:  7, size: 64}
      "r8"  -> %Register{name: "r8",  reg:  8, size: 64}
      "r9"  -> %Register{name: "r9",  reg:  9, size: 64}
      "r10" -> %Register{name: "r10", reg: 10, size: 64}
      "r11" -> %Register{name: "r11", reg: 11, size: 64}
      "r12" -> %Register{name: "r12", reg: 12, size: 64}
      "r13" -> %Register{name: "r13", reg: 13, size: 64}
      "r14" -> %Register{name: "r14", reg: 14, size: 64}
      "r15" -> %Register{name: "r15", reg: 15, size: 64}
      # 32-bit
      "eax"  -> %Register{name: "eax",  reg:  0, size: 32}
      "ecx"  -> %Register{name: "ecx",  reg:  1, size: 32}
      "edx"  -> %Register{name: "edx",  reg:  2, size: 32}
      "ebx"  -> %Register{name: "ebx",  reg:  3, size: 32}
      "esp"  -> %Register{name: "esp",  reg:  4, size: 32}
      "ebp"  -> %Register{name: "ebp",  reg:  5, size: 32}
      "esi"  -> %Register{name: "esi",  reg:  6, size: 32}
      "edi"  -> %Register{name: "edi",  reg:  7, size: 32}
      "r8d"  -> %Register{name: "r8d",  reg:  8, size: 32}
      "r9d"  -> %Register{name: "r9d",  reg:  9, size: 32}
      "r10d" -> %Register{name: "r10d", reg: 10, size: 32}
      "r11d" -> %Register{name: "r11d", reg: 11, size: 32}
      "r12d" -> %Register{name: "r12d", reg: 12, size: 32}
      "r13d" -> %Register{name: "r13d", reg: 13, size: 32}
      "r14d" -> %Register{name: "r14d", reg: 14, size: 32}
      "r15d" -> %Register{name: "r15d", reg: 15, size: 32}
      _no_  -> name
    end
  end

  def create(name), do: name
end
