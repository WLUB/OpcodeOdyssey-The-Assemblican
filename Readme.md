# Opcode Odyssey: The Assemblican

This is a lightweight assembler/disassembler for the AVR architecture. It's a simple program created as a fun proof-of-concept project. Currently, it supports only a limited set of instructions, but it's designed to be easily extensible for additional instruction support. Note that memory layout selection is not currently supported.

## Syntax

The assembly syntax uses spaces instead of commas to separate operands. For example:

```
loop:
ldi r16 0x1b
ldi r17 31
rjmp loop
```

## How to Build

Compile the project to an executable with `mix escript.build` or run it it via `iex -S mix`