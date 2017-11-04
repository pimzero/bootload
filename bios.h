#ifndef BIOS_H
#define BIOS_H

#include <stdint.h>
#include <stddef.h>
#include "data.h"

struct {
	uint16_t limit;
	void* base;
} __packed idtr = {
	.limit = 0x3FF,
	.base = NULL,
};

void* sp;

#define PUSHALL(esc) \
	"push " #esc "eax\n\t" \
	"push " #esc "ebx\n\t" \
	"push " #esc "ecx\n\t" \
	"push " #esc "edx\n\t" \
	"push " #esc "esi\n\t" \
	"push " #esc "edi\n\t" \
	"push " #esc "ebp\n\t" \

#define POPALL(esc) \
	"pop " #esc "ebp\n\t" \
	"pop " #esc "edi\n\t" \
	"pop " #esc "esi\n\t" \
	"pop " #esc "edx\n\t" \
	"pop " #esc "ecx\n\t" \
	"pop " #esc "ebx\n\t" \
	"pop " #esc "eax\n\t" \

#define SAVE_STACK(esc) \
	PUSHALL(esc)
//"mov " #esc "esp, $sp\n\t"

#define RESTORE_STACK(esc) /* "mov $sp, " #esc "esp\n\t" */ \
	POPALL(esc)

#define X86_RM(reg, esc) \
	\
	"cli\n\t" \
	"lidt idtr\n\t" \
	\
	"mov $0x20, " #esc #reg "\n\t" \
	"mov " #esc #reg ", " #esc "ds\n\t" \
	"mov " #esc #reg ", " #esc "es\n\t" \
	"mov " #esc #reg ", " #esc "fs\n\t" \
	"mov " #esc #reg ", " #esc "gs\n\t" \
	"mov " #esc #reg ", " #esc "ss\n\t" \
	\
	"ljmp $0x18, $1f\n" \
	"1:\n" \
	".code16\n\t" \
	\
	"mov " #esc "cr0, " #esc "e" #reg "\n\t" \
	"dec " #esc "e" #reg "\n\t" \
	"mov " #esc "e" #reg ", " #esc "cr0\n\t" \
	\
	"ljmp $0x0, $1f\n" \
	"1:\n\t" \
	\
	"mov $0x0, " #esc #reg "\n\t" \
	"mov " #esc #reg ", " #esc "ds\n\t" \
	"mov " #esc #reg ", " #esc "es\n\t" \
	"mov " #esc #reg ", " #esc "fs\n\t" \
	"mov " #esc #reg ", " #esc "gs\n\t" \
	"mov " #esc #reg ", " #esc "ss\n\t" \
	\
	//"xorl " #esc "ebp, " #esc "ebp\n\t" \
	//"mov " #esc "ebp, " #esc "esp \n\t"

#define X86_PM(reg, esc) \
	"lgdt gdtr\n\t" \
	"smsw " #esc #reg "\n\t" \
	"or $1, " #esc #reg "\n\t" \
	"lmsw " #esc #reg "\n\t" \
	\
	"ljmp $0x8, $1f\n" \
	"1:\n" \
	".code32\n\t" \
	\
	"mov $0x10, " #esc #reg "\n\t" \
	"mov " #esc #reg ", " #esc "ds\n\t" \
	"mov " #esc #reg ", " #esc "es\n\t" \
	"mov " #esc #reg ", " #esc "fs\n\t" \
	"mov " #esc #reg ", " #esc "gs\n\t" \
	"mov " #esc #reg ", " #esc "ss\n\t"


static void bios_int(char nr, short c)
{
	asm(SAVE_STACK(%%)
	    "mov %%bl, interrupt_nr\n\t"
	    X86_RM(bx, %%)
	    "mov $0x0e, %%ah\n"
	    // self modifying int
	    ".byte 0xcd\n"
	    "interrupt_nr:\n"
	    ".byte 0x0\n\t"
	    X86_PM(bx, %%)
	    RESTORE_STACK(%%)
	     : : "a"(c), "b"(nr));
//mov $0x43, %al  #   ; AL = code of character to display
}

#define print_char(C) (bios_int(0x10, (0x0e << 8) | (C)))

#endif
