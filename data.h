#include <stdint.h>

#define __packed __attribute__((__packed__))

struct gdte {
	uint16_t limit_low;
	uint16_t base_low;
	uint8_t base_mid;
	uint8_t access:7;
	uint8_t p:1;
	uint8_t limit_mid:4;
	uint8_t avl:1;
	uint8_t l:1;
	uint8_t db:1;
	uint8_t granularity:1;
	uint8_t base_high;
} __packed;

struct gdtr {
	uint16_t limit;
	void* base;
} __packed;

extern struct gdte gdt[];
extern struct gdtr gdtr;
