#ifndef BIOS_H
#define BIOS_H

#include <stddef.h>
#include <stdint.h>

struct regs {
	uint16_t a;
	uint16_t b;
	uint16_t c;
	uint16_t d;
};

void bios_int(uint8_t nr, struct regs* regs);

#define pr_char(C) { struct regs __r = { .a = (0x0e << 8) | (C) }; bios_int(0x10, &__r); }
#define pr_str(Str) { for (size_t i = 0; (Str)[i]; i++) pr_char((Str)[i]); }

#define disk_status() ({ struct regs __r = { .a = (1 << 8) }; bios_int(0x13, &__r); __r.a; })

#endif
