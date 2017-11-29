.global __entry

__entry:

call dev_driver

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
