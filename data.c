#include <stdint.h>

#include "data.h"

#define CODE_SEGMENT(Dpl) (((Dpl) << 5) | (1 << 4) | 0xA)
#define DATA_SEGMENT(Dpl) (((Dpl) << 5) | (1 << 4) | 0x2)

struct gdte gdt[] = {
	{ },
	{
		.limit_low = 0xffff,
		.base_low = 0x0,
		.base_mid = 0x0,
		.access = CODE_SEGMENT(0),
		.p = 1,
		.limit_mid = 0xf,
		.avl = 0,
		.l = 0,
		.db = 1,
		.granularity = 1,
		.base_high = 0x0,
	},
	{
		.limit_low = 0xffff,
		.base_low = 0x0,
		.base_mid = 0x0,
		.access = DATA_SEGMENT(0),
		.p = 1,
		.limit_mid = 0xf,
		.avl = 0,
		.l = 0,
		.db = 1,
		.granularity = 1,
		.base_high = 0x0,
	},
	{
		.limit_low = 0xffff,
		.base_low = 0x0,
		.base_mid = 0x0,
		.access = CODE_SEGMENT(0),
		.p = 1,
		.limit_mid = 0xf,
		.avl = 0,
		.l = 0,
		.db = 0,
		.granularity = 0,
		.base_high = 0x0,
	},
	{
		.limit_low = 0xffff,
		.base_low = 0x0,
		.base_mid = 0x0,
		.access = DATA_SEGMENT(0),
		.p = 1,
		.limit_mid = 0xf,
		.avl = 0,
		.l = 0,
		.db = 0,
		.granularity = 0,
		.base_high = 0x0,
	},
};

struct gdtr gdtr = {
	.base = gdt,
	.limit = sizeof(gdt) - 1,
};

