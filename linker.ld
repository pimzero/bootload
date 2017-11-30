SECTIONS
{
    . = 0x7C00 + 0x3e;
    .text : AT(0x7C00 + 0x3e)
    {
        *(.boot)
        *(.text);
    }
    .data :
    {
        *(.bss);
        *(.bss*);
        *(.data);
        *(.rodata*);
        *(COMMON)
    }
    .sig : AT(0x7DFE)
    {
        SHORT(0xaa55);
    }
    /DISCARD/ :
    {
        *(.note*);
        *(.iplt*);
        *(.igot*);
        *(.rel*);
        *(.comment);
/* add any unwanted sections spewed out by your version of gcc and flags here */
    }
}
