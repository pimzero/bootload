.global __entry

__entry:

sub $0x808, %esp

lea 8(%esp), %ebx
mov $0x204, %eax
mov $2, %ecx
xor %edx, %edx
mov $0x13, %ebp
call bios_int

lea 8(%esp), %edx

call loader_elf

add $0x808, %esp
jmp *%eax

mov $0x0e41, %ax
mov $0x10, %ebp
call bios_int
1:

jmp 1b

.global panic
panic:
mov $0x0e42, %ax
mov $0x10, %ebp
call bios_int

1:
jmp 1b
