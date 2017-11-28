.global idtr

/*
 * eax, ebx, ecx, edx = int args
 * ebp = int number (dropped)
 */

.global bios_int
bios_int:

xchg %ebp, %ebx

mov %bl, interrupt_nr

push %ebp

mov $0x20, %bl
call bl_to_segm

ljmp $0x18, $1f
1:
.code16

sti

mov %cr0, %ebx
dec %ebx
mov %ebx, %cr0

ljmp $0x0, $1f
1:

xor %bx, %bx
call bl_to_segm

pop %ebx

// self modifying int
.byte 0xcd
interrupt_nr:
.byte 0x0

call go_pm
.code32

cli

mov $0x10, %bl

.global bl_to_segm
bl_to_segm:

push %bx

xor %bh, %bh

mov %bx, %ds
mov %bx, %es
mov %bx, %fs
mov %bx, %gs
mov %bx, %ss

pop %bx

ret

.code16
.global go_pm
/* Drop bp */
go_pm:

lgdt gdtr
smsw %bp
or $1, %bp
lmsw %bp

.code32
popl %ebp
pushl $0x8
pushl %ebp
lret
