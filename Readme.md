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
Instead of `[rel <label>]` or `<label>` use `#<label>`.   
The assembly syntax uses spaces instead of commas to separate operands.   

```
; Example program demonstrating
; how the syntax looks

extern _printf
global _main

section .text

external_function:
    lea     rdi #hello_printf   
    xor     eax eax             
    call    #_printf           
    ret     ; inline comments is
            ; allowed
function:
    mov     eax 0x2000004
    mov     edi 1
    lea     rsi #hello
    mov     edx 0b1110
    syscall
    ret

_main:
    call    #function
    call    #external_function

    mov     eax 0x2000001
    xor     edi edi
    syscall

section .data
    hello: db "Hello, World!", 0x0A, 0x00
    hello_printf: db "Hello from printf!", 0x0A, 0x00
```
### Creating an executable
The assembler will generate an object file, in order to make it into an executable you need to link it.
```
ld hello.o -o hello
```

## How to Build
Compile the project to an executable with `mix escript.build` or run it via `iex -S mix`
