#include <stdint.h>
#include <stddef.h>

#include "bios.h"
#include "data.h"

struct {
	uint16_t limit;
	void* base;
} __packed idtr = {
	.limit = 0x3FF,
	.base = NULL,
};

void* sp;

#if 0
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
	"pop " #esc "eax\n\t"
#else
#define PUSHALL(esc) ""
#define POPALL(esc) ""
#endif

#define SAVE_STACK(esc) \
	PUSHALL(esc)
//"mov " #esc "esp, $sp\n\t"

#define RESTORE_STACK(esc) /* "mov $sp, " #esc "esp\n\t" */ \
	POPALL(esc)

#define X86_RM(reg, esc) \
	\
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
	"sti\n\t" \
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
	"cli\n\t" \
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


void bios_int(uint8_t nr, struct regs* regs)
{
#if 0
	uint16_t a = regs->a;
	uint16_t b = regs->b;
	uint16_t c = regs->c;
	uint16_t d = regs->d;
#endif
	asm volatile (
	     SAVE_STACK(%%)
	    "mov %%bx, interrupt_nr\n\t"
	     : : "b"(nr));

	asm volatile (
	    X86_RM(di, %%)
	    // self modifying int
	    ".byte 0xcd\n"
	    "interrupt_nr:\n"
	    ".byte 0x0\n\t"
	     : "=&a"(regs->a), "+b"(regs->b), "+c"(regs->c), "+d"(regs->d));
	asm volatile(
	    "xor %ebx, %ebx\n\t"
	    X86_PM(bx,%)
	    RESTORE_STACK(%));

#if 0
	regs->a = a;
	regs->b = b;
	regs->c = c;
#endif
//mov $0x43, %al  #   ; AL = code of character to display
}
