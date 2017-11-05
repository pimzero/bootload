.global idtr

.global bios_int
bios_int:

pop %ecx
pop %ebx
pop %eax
mov %bl, interrupt_nr
push %ecx

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

push %ebp
mov %esp, %ebp
mov %eax, %esp
pop %ax
pop %bx
pop %cx
pop %dx
sub $8, %esp
xchg %ebp, %esp

// self modifying int
.byte 0xcd
interrupt_nr:
.byte 0x0

mov %ax, (%ebp)
mov %bx, 2(%ebp)
mov %cx, 4(%ebp)
inc %ebp
inc %ebp
mov %dx, 4(%ebp)
pop %ebp

call go_pm
.code32

cli

mov $0x10, %bl

.global bl_to_segm
bl_to_segm:

xor %bh, %bh

mov %bx, %ds
mov %bx, %es
mov %bx, %fs
mov %bx, %gs
mov %bx, %ss

ret

.code16
.global go_pm
go_pm:

lgdt gdtr
smsw %bx
or $1, %bx
lmsw %bx

.code32
popl %eax
pushl $0x8
pushl %eax
lret
