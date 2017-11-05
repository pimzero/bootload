#include "bios.h"

void __entry()
{

	struct regs r = { .a = (1 << 8)};
	bios_int(0x11, &r);
	pr_char('a' + ((r.a >> 8) & 0xf));
	pr_char('a' + (r.a & 0xf));
	while (1)
		;
}
