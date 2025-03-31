# Opcode Odyssey: The Assemblican

This is a lightweight assembler/disassembler for the AVR architecture. It's a simple program created as a fun proof-of-concept project. Currently, it supports only a limited set of instructions, but it's designed to be easily extensible for additional instruction support.

## Syntax

The assembly syntax uses spaces instead of commas to separate operands. For example:

```
loop:
ldi r16 0x1b
ldi r17 31
rjmp loop
```
## Supported Features
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

## How to Build

Compile the project to an executable with `mix escript.build` or run it via `iex -S mix`