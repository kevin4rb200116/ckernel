bits 32

section .note.GNU-stack
section .text
  extern asm_putc
  extern asm_puts
  extern puts
  extern _init
  extern main

  global info32
  info32:
    push ebp
    mov ebp, esp

    lea ecx,[.msg]
    mov [show.type],ecx
    jmp show

  global error32
  error32:
    push ebp
    mov ebp, esp

    lea ecx,[.msg]
    mov [show.type],ecx
    jmp show

  show:
    mov [.msg],edi

    mov edi,[.type]
    call asm_puts

    mov edi,[.msg]
    call asm_puts

    mov edi,0xA
    call asm_putc

    pop ebp
    ret

  global panic32
  panic32:
    push ebp
    mov ebp, esp

    lea edi,[.halt]
    call asm_puts

    hlt
    jmp $

    pop ebp
    ret

  global check_blmagic
  check_blmagic:
    push ebp
    mov ebp, esp

    mov [.magic],edi

    .0if nop
      mov eax,[.magic]
      cmp eax,0x36D76289

      jne .0else
      .0if.then nop
        mov eax,0x1
        jmp .0endif

      .0else nop
        lea edi,[.const.error]
        call error32

        mov eax,0x0
    .0endif nop

    pop ebp
    ret

  global check_cpuid
  check_cpuid:
    ; Check if CPUID is supported by attempting to flip the ID bit (bit 21)
    ; in the FLAGS register. If we can flip it, CPUID is available.

    push ebp
    mov ebp,esp

    ; Copy FLAGS in to EAX via stack
    pushfd
    pop eax

      ; Copy to ECX as well for comparing later on
    mov ecx,eax

    ; Flip the ID bit
    xor eax, 1 << 21

    ; Copy EAX to FLAGS via the stack
    push eax
    popfd

    ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pushfd
    pop eax

    ; Restore FLAGS from the old version stored in ECX (i.e. flipping the
    ; ID bit back if it was ever flipped).
    push ecx
    popfd

    ; Compare EAX and ECX. If they are equal then that means the bit
    ; wasn't flipped, and CPUID isn't supported.
    .0if nop
      cmp eax,ecx

      jne .0endif
      .0if.then nop
        lea edi,[.const.error_msg]
        call error32
        mov eax,0x0
    .0endif nop

    mov eax,0x1
    pop ebp
    ret

  global check_long_mode
  check_long_mode:
    push ebp
    mov ebp, esp

    .0if nop
      ; test if extended processor info in available
      mov eax, 0x80000000    ; implicit argument for cpuid
      cpuid                  ; get highest supported argument
      cmp eax, 0x80000001    ; it needs to be at least 0x80000001

      jb .0else              ; if it's less, the CPU is too old for long mode

      ; use extended info to test if long mode is available
      mov eax, 0x80000001    ; argument for extended processor info
      cpuid                  ; returns various feature bits in ecx and edx
      test edx, 1 << 29      ; test if the LM-bit is set in the D-register

      jz .0else              ; If it's not set, there is no long mode
      .0if.then nop
        mov eax,0x1
        jmp .0endif

      .0else nop
        lea edi,[.const.error_msg]
        call error32
        mov eax,0x0
    .0endif nop

    pop ebp
    ret

  ; The kernel entry point.
  global _start
  _start:
    ; Initialize the stack pointer.
    lea esp, [.stack+16384]

    ; Reset EFLAGS.
    push dword 0x00
    popf

    ; eax and ebx contain information that the boot loader has passed to us
    ; Store the magic value.
    mov [.mb_magic],eax
    ; Store the pointer to the Multiboot information structure.
    mov [.mb_addr],ebx

    .0if nop
      mov edi,[.mb_magic]
      call check_blmagic
      cmp eax,0x1

      jne _start_die
      .0if.then nop
        lea edi,[.const.check_blmagic_msg]
        call info32
    .0endif nop

    .1if nop
      call check_cpuid
      cmp eax,0x1

      jne _start_die
      .1if.then nop
        lea edi,[.const.check_cpuid_msg]
        call info32
        jmp .1endif
    .1endif nop

    .2if nop
      call check_long_mode
      cmp eax,0x1

      jne _start_die
      .2if.then nop
        lea edi,[.const.check_long_mode_msg]
        call info32
        jmp .2endif
    .2endif nop

    ; enable PAE and PSE
    mov eax, cr4
    or eax, (CR4_PAE + CR4_PSE)
    mov cr4, eax

    ; enable long mode and the NX bit
    mov ecx, MSR_EFER
    rdmsr
    or eax, (EFER_LM + EFER_NX)
    wrmsr

    ; set cr3 to a pointer to pml4
    mov eax, .boot_pml4
    mov cr3, eax

    ; enable paging
    mov eax, cr0
    or eax, CR0_PAGING
    mov cr0, eax

    cli
    lgdt [.gdtr]
    mov ax, 0x10
    mov ss, ax
    mov ax, 0x0
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    jmp 0x08:_start_long

    _start_die:
      call panic32

  bits 64
  _start_long:
    ; set up the new stack (multiboot2 spec says the stack pointer could be
    ; anything - even pointing to invalid memory)
    mov rbp,0 ; terminate stack traces here
    lea rsp,qword [_start.stack+16384]

    ; clear the RFLAGS register
    push 0x0
    popf

    ; Call the global constructors.
    call _init

    ; Transfer control to the main kernel.
    mov edi,[_start.mb_magic]
    mov esi,[_start.mb_addr]
    call main

  _start_long_die:
    ; Hang if kernel_main unexpectedly returns.
    cli

    hlt
    jmp _start_long_die

section .rodata
  _start.const.check_blmagic_msg db "check_blmagic()",0x00
  _start.const.check_cpuid_msg db "check_cpuid()",0x00
  _start.const.check_long_mode_msg db "check_long_mode()",0x00

  info32.msg db "[ Info ] ", 0x00
  error32.msg db "[ Error ] ", 0x00

  panic32.halt db "System Halted!",0x00

  check_blmagic.const.error db "invalid multiboot header",0x00
  check_cpuid.const.error_msg db "no cpuid support",0x00
  check_long_mode.const.error_msg db "no long mode support",0x00

; Reserve a stack for the initial thread.
section .bss
  _start.stack resb 16384
  _start.mb_magic resd 1
  _start.mb_addr resq 1

  show.type resd 1
  show.msg resd 1

  check_blmagic.magic resd 1

section .paging align=4096
  ; MSR numbers
  MSR_EFER equ 0xC0000080

  ; EFER bitmasks
  EFER_LM equ 0x100
  EFER_NX equ 0x800

  ; CR0 bitmasks
  CR0_PAGING equ 0x80000000

  ; CR4 bitmasks
  CR4_PAE equ 0x20
  CR4_PSE equ 0x10

  ; page flag bitmasks
  PG_PRESENT  equ 0x1
  PG_WRITABLE equ 0x2
  PG_USER     equ 0x4
  PG_BIG      equ 0x80
  PG_NO_EXEC  equ 0x8000000000000000

  ; page and table size constants
  LOG_TABLE_SIZE equ 9
  LOG_PAGE_SIZE  equ 12
  PAGE_SIZE  equ (1 << LOG_PAGE_SIZE)
  TABLE_SIZE equ (1 << LOG_TABLE_SIZE)

  global _start.boot_pml4
  _start.boot_pml4:
    dq (_start.boot_pml3l + PG_PRESENT + PG_WRITABLE)
    times (TABLE_SIZE - 4) dq 0
    dq (_start.identity_pml3 + PG_PRESENT + PG_WRITABLE)
    dq (_start.boot_pml4 + PG_PRESENT + PG_WRITABLE + PG_NO_EXEC)
    dq (_start.boot_pml3h + PG_PRESENT + PG_WRITABLE)

  _start.boot_pml3l:
    dq (_start.boot_pml2 + PG_PRESENT + PG_WRITABLE)
    dq 0
    times (TABLE_SIZE - 2) dq 0

  _start.boot_pml3h:
    times (TABLE_SIZE - 2) dq 0
    dq (_start.boot_pml2 + PG_PRESENT + PG_WRITABLE)
    dq 0

  _start.boot_pml2:
    dq (0x0 + PG_PRESENT + PG_WRITABLE + PG_BIG)
    times (TABLE_SIZE - 1) dq 0

  _start.identity_pml3:
    times (TABLE_SIZE - 5) dq 0
    dq (_start.pmm_stack_pml2 + PG_PRESENT + PG_WRITABLE)
    dq (_start.identity_pml2a + PG_PRESENT + PG_WRITABLE)
    dq (_start.identity_pml2b + PG_PRESENT + PG_WRITABLE)
    dq (_start.identity_pml2c + PG_PRESENT + PG_WRITABLE)
    dq (_start.identity_pml2d + PG_PRESENT + PG_WRITABLE)

  _start.pmm_stack_pml2:
    times (TABLE_SIZE - 1) dq 0
    dq (_start.pmm_stack_pml1 + PG_PRESENT + PG_WRITABLE)

  _start.pmm_stack_pml1:
    times TABLE_SIZE dq 0

  _start.identity_pml2a:
    %assign pg 0
    %rep TABLE_SIZE
      dq (pg + PG_PRESENT + PG_WRITABLE + PG_BIG + PG_NO_EXEC)
      %assign pg pg+PAGE_SIZE*TABLE_SIZE
    %endrep

  _start.identity_pml2b:
    %rep TABLE_SIZE
      dq (pg + PG_PRESENT + PG_WRITABLE + PG_BIG + PG_NO_EXEC)
      %assign pg pg+PAGE_SIZE*TABLE_SIZE
    %endrep

  _start.identity_pml2c:
    %rep TABLE_SIZE
      dq (pg + PG_PRESENT + PG_WRITABLE + PG_BIG + PG_NO_EXEC)
      %assign pg pg+PAGE_SIZE*TABLE_SIZE
    %endrep

  _start.identity_pml2d:
    %rep TABLE_SIZE
      dq (pg + PG_PRESENT + PG_WRITABLE + PG_BIG + PG_NO_EXEC)
      %assign pg pg+PAGE_SIZE*TABLE_SIZE
    %endrep

  ; the global descriptor table
  _start.gdt:
    ; null selector
    dq 0
    ; cs selector
    dq 0x00AF98000000FFFF
    ; ds selector
    dq 0x00CF92000000FFFF
    _start.gdt.end dq 0 ; some extra padding so the gdtr is 16-byte aligned

  _start.gdtr:
    dw _start.gdt.end - _start.gdt - 1
    dq _start.gdt
