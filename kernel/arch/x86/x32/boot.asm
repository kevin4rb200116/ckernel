bits 32

section .note.GNU-stack
section .text
  ; extern asm_putc.attr
  extern puts
  extern _init
  extern main

  ; The kernel entry point.
  global _start
  _start:
    ; Reserve a stack for the initial thread.
    section .bss
        .stack resb 16384
        .mb_magic resd 1
        .mb_addr resd 1
    section .text

    ; Initialize the stack pointer.  
    lea esp, [.stack+16384]

    ; Reset EFLAGS.
    push dword 0x00
    popf

    ; Store the magic value.
    mov [.mb_magic],eax
    ; Store the pointer to the Multiboot information structure.
    mov [.mb_addr],ebx

    ; Call the global constructors.
    call _init

    ; Transfer control to the main kernel.
    mov ebx,[.mb_addr]
    push ebx
    mov eax,[.mb_magic]
    push eax
    call main

    ; Hang if kernel_main unexpectedly returns.
    cli

    section .rodata
      const.halt db "System Halted!", 0xa, 0x00
    section .text

    lea edi, [const.halt]
    push edi
    call puts

    _start.die:
      hlt
      jmp $
