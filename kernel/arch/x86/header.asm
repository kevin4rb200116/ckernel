bits 32

section .note.GNU-stack
section .multiboot align=8

MULTIBOOT2_HEADER_MAGIC equ 0xE85250D6
GRUB_MULTIBOOT_ARCHITECTURE_I386 equ 0

MULTIBOOT_HEADER_TAG_OPTIONAL equ 1
MULTIBOOT_TAG_TYPE_MODULE equ 3
MULTIBOOT_TAG_TYPE_MMAP equ 6

MULTIBOOT_HEADER_TAG_END                 equ 0
MULTIBOOT_HEADER_TAG_INFORMATION_REQUEST equ 1
MULTIBOOT_HEADER_TAG_ADDRESS             equ 2
MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS       equ 3
MULTIBOOT_HEADER_TAG_CONSOLE_FLAGS       equ 4
MULTIBOOT_HEADER_TAG_FRAMEBUFFER         equ 5
MULTIBOOT_HEADER_TAG_MODULE_ALIGN        equ 6
MULTIBOOT_HEADER_TAG_EFI_BS              equ 7
MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS_EFI32 equ 8
MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS_EFI64 equ 9
MULTIBOOT_HEADER_TAG_RELOCATABLE         equ 10

extern kernel_begin
extern kernel_end
extern bss_begin
extern bss_end
extern _start

; Declare a header as in the Multiboot Standard.
header:
  .magic         dd MULTIBOOT2_HEADER_MAGIC
  .architecture  dd GRUB_MULTIBOOT_ARCHITECTURE_I386
  .header_length dd (header.end - header)
  .checksum      dd -(MULTIBOOT2_HEADER_MAGIC + GRUB_MULTIBOOT_ARCHITECTURE_I386 + (header.end - header))

  ; header.info_tag:
  ;   .type     dw MULTIBOOT_HEADER_TAG_INFORMATION_REQUEST
  ;   .flags    dw MULTIBOOT_HEADER_TAG_OPTIONAL
  ;   .size     dd (header.terminator_tag - header.info_tag)
  ;   .request0 dd MULTIBOOT_TAG_TYPE_MODULE
  ;   .request1 dd MULTIBOOT_TAG_TYPE_MMAP

  ; header.address_tag:
  ;   .type          dw MULTIBOOT_HEADER_TAG_ADDRESS
  ;   .flags         dw MULTIBOOT_HEADER_TAG_OPTIONAL
  ;   .size          dd (header.entry_address - header.address_tag)
  ;   .header_addr   dd header
  ;   .load_addr     dd kernel_begin
  ;   .load_end_addr dd kernel_end
  ;   .bss_end_addr  dd bss_end

  ; header.entry_address:
  ;   .type       dw MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS
  ;   .flags      dw MULTIBOOT_HEADER_TAG_OPTIONAL
  ;   .size       dd (header.terminator_tag - header.entry_address)
  ;   .entry_addr dd _start

  ; header.framebuffer_tag:
  ;   .type dw MULTIBOOT_HEADER_TAG_FRAMEBUFFER
  ;   .flags dw MULTIBOOT_HEADER_TAG_OPTIONAL
  ;   .size dd (header.terminator_tag - header.framebuffer_tag)
  ;   .width dd 800
  ;   .height dd 600
  ;   .depth dd 32

  header.terminator_tag:
    .type  dw MULTIBOOT_HEADER_TAG_END
    .flags dw 0x00
    .size  dd 0x00
header.end:
  dd 0x00
  dd 0x00
