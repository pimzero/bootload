.text
.code16
.global __entry
cli

lgdt gdtr

#jmp 1f
#1:

# PM mode
smsw %dx
or $1, %dx
lmsw %dx

ljmp $0x8, $1f
1:

.code32

mov $0x10, %ax
mov %ax, %ds
mov %ax, %es
mov %ax, %fs
mov %ax, %gs
mov %ax, %ss

call __entry
