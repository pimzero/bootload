.global floppy_driver
.global dev_driver
/* Noreturn */

floppy_driver:
dev_driver:
sub $0x1008, %esp

lea 8(%esp), %ebx
push %ebx

mov $0x201, %eax
mov $2, %ecx
xor %edx, %edx
mov $0x13, %ebp
call bios_int

mov $0x0e44, %ax
mov $0x10, %ebp
call bios_int

pop %edx

call loader_elf

add $0x1008, %esp
jmp *%eax
