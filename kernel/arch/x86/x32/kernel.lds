OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)

PAGE_SIZE  = 0x1000;
KERNEL_VMA = 0xc0000000;
UPPER_MEM  = 0x100000;

SECTIONS {
	. = UPPER_MEM;

	kernel_begin = . + KERNEL_VMA;

	.text ALIGN(PAGE_SIZE) : AT(ADDR(.text) - KERNEL_VMA) {
		*(.multiboot)
		*(.text)
	}

	.data ALIGN(PAGE_SIZE) : AT(ADDR(.data) - KERNEL_VMA) {
		*(.data)
	}

	.rodata ALIGN(PAGE_SIZE) : AT(ADDR(.rodata) - KERNEL_VMA) {
		*(.rodata)
	}

	.bss ALIGN(PAGE_SIZE) : AT(ADDR(.bss) - KERNEL_VMA) {
		bss_begin = .;
		*(COMMON)
		*(.bss)
		bss_end = .;
	}

	kernel_end = .;
}
