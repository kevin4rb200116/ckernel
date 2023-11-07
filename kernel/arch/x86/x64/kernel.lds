OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

PAGE_SIZE  = 0x1000;
UPPER_MEM  = 0x100000;

SECTIONS {
	. = UPPER_MEM;

	kernel_begin = .;

	.text ALIGN(PAGE_SIZE) : {
		*(.multiboot)
		*(.text)
	}

	.data ALIGN(PAGE_SIZE) : {
		*(.data)
	}

	.rodata ALIGN(PAGE_SIZE) : {
		*(.rodata)
	}

	.bss ALIGN(PAGE_SIZE) : {
		bss_begin = .;
		*(COMMON)
		*(.bss)
		bss_end = .;
	}

	kernel_end = .;
}