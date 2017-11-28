#include "bios.h"

static void pr_hex(unsigned char a)
{
	if (a >= 10)
		a += 'a' - '0' - 10;
	pr_char('0' + a);
}

static void pr_byte(unsigned char c)
{
	pr_hex((c >> 4) & 0xf);
	pr_hex(c & 0xf);
}
char* s = "bites";

void __entry(int disk)
{
#if 0
	pr_hex((disk >> 8) & 0xf);
	pr_hex(disk & 0xf);
#endif

	struct regs r = { 0 };
	//bios_int(0x11, &r);
	//pr_char('a' + ((r.a >> 8) & 0xf));
	//pr_char('a' + (r.a & 0xf));

	unsigned char buf[1024] = { 0 };

	r.b = (uint32_t)buf;
	r.a = 0x0202;
	r.c = 1;

	bios_int(0x13, &r);

	for (size_t i = 0; i < sizeof(buf); i++) {
		//pr_hex((buf[i] >> 8) & 0xf);
		//pr_hex(buf[i] & 0xf);
#if 0
		if (buf[i] >= 0x20 && buf[i] < 0x7f)
			pr_char(buf[i]);
#endif
		pr_byte(buf[i]);
	}

	while (1)
		;
}
