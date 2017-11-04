#ifndef BIOS_H
#define BIOS_H

void bios_int(char nr, short c);

#define print_char(C) (bios_int(0x10, (0x0e << 8) | (C)))

#endif
