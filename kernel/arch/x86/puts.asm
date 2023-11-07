bits 32

VGAColorBlack        equ 0x0
VGAColorBlue         equ 0x1
VGAColorGreen        equ 0x2
VGAColorCyan         equ 0x3
VGAColorRed          equ 0x4
VGAColorMagenta      equ 0x5
VGAColorBrown        equ 0x6
VGAColorLightGrey    equ 0x7
VGAColorDarkGrey     equ 0x8
VGAColorLightBlue    equ 0x9
VGAColorLightGreen   equ 0xA
VGAColorLightCyan    equ 0xB
VGAColorLightRed     equ 0xC
VGAColorLightMagenta equ 0xD
VGAColorLightBrown   equ 0xE
VGAColorWhite        equ 0xF

section .note.GNU-stack
section .text

global asm_putc
asm_putc:
  push ebp
  mov ebp, esp

  section .bss
    .char resd 1

    .xpos resb 1
    .ypos resb 1
  section .text

  .0if nop
    cmp edi,0xD

    jne .0elif
    .0if.then nop
      jmp .0endif

    .0elif nop
      cmp edi,0xA

      jne .0else
      .0elif.then nop
        add byte[.ypos],1    ; newline
        mov byte[.xpos],0
        jmp .0endif

    .0else nop
      mov eax,edi
      mov ah,(VGAColorLightGrey|(VGAColorBlack<<4)) ; attrib = white on black

      mov [asm_putc.char],eax ; save char/attribute

      movzx eax, byte[.ypos]
      mov edx, 160             ; 2 bytes (char/attrib)
      mul edx                  ; for 80 columns
      movzx ebx, byte[.xpos]
      shl ebx, 1               ; times 2 to skip attrib

      mov edi, 0xb8000         ; start of video memory
      add edi, eax             ; add y offset
      add edi, ebx             ; add x offset

      movzx eax,word[asm_putc.char] ; restore char/attribute
      mov word[ds:edi],ax
      add byte[.xpos],1      ; advance to right
  .0endif nop

  pop ebp
  ret

global asm_puts
asm_puts:
  push ebp
  mov ebp, esp

  section .bss
    .string resd 1
  section .text

  mov [.string],edi
  mov eax,[.string]
  movzx edi,byte[eax]

  .0for nop
    .0for.initial_value nop
    .0for.condition nop
      mov eax,[.string]
      movzx edi,byte[eax]

      cmp di,0x00

      je .0endfor
      jmp .0for.body

    .0for.increment nop
      inc dword[.string]
      jmp .0for.condition

    .0for.body nop
      call asm_putc

      jmp .0for.increment
  .0endfor nop

  pop ebp
  ret
