.global panic
panic:
mov $0x0e42, %ax
mov $0x10, %ebp
call bios_int

1:
jmp 1b
