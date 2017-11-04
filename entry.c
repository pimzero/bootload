#include "bios.h"

void __entry()
{
	volatile short* fb = (void*)0xb8000;
	fb[0] = 0xffff;
	print_char('4');
	fb[1] = 0xffff;
	fb[2] = 0xffff;
	while (1)
		fb[3] = 0xffff;
}
