# Opcode Odyssey: The Assemblican

This is a lightweight assembler/disassembler for the AVR and Intel64 architecture. It's a simple program created as a fun proof-of-concept project. Currently, it supports only a limited set of instructions, but it's designed to be easily extensible for additional instruction support.

## AVR
### Syntax

The assembly syntax uses spaces instead of commas to separate operands. For example:

```
loop:
ldi r16 0x1b
ldi r17 31
rjmp loop
```
### Supported Features
| Directives    | 
| ------------- |
| .org          |

| Instructions  | 
| ------------- |
| LDI           |
| NOP           |
| RCALL         |
| RJMP          |
| RET           |
| STS           |

- Labels are supported.
- Number representation base-16 (`0x`)
- Number representation base-2 (`0b`)

## Intel64
Disassembling is currently not supported. The output targets 64-bit Mach-O files with a minimum OS and SDK version of 13. Many features and functionalities are missing and will likely never be supported.

### Syntax
Instead of `[rel <name>]` use `#<name>`. 
In the data section only text token is supported. 

```
global _main
section .text
_main:
mov rax 0x2000004
mov rdi 1
lea rsi #hello
mov rdx 13
syscall

mov rax 0x2000001
mov rdi 0
syscall

section .data
hello: db Hello, World!\0
```
### Creating an executable
The assembler will generate an object file, in order to make it into an executable you need to link it.
```
ld hello.o -o hello
```

## How to Build
Compile the project to an executable with `mix escript.build` or run it via `iex -S mix`
