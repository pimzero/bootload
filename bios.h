#ifndef BIOS_H
#define BIOS_H

#include <stdint.h>

struct regs {
	uint16_t a;
	uint16_t b;
	uint16_t c;
	uint16_t d;
};

void bios_int(uint8_t nr, struct regs* regs);

#define print_char(C) { struct regs __r = { .a = (0x0e << 8) | (C) }; bios_int(0x10, &__r); }

#endif
