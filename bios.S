.global idtr

.global bios_int
bios_int:

pop %ecx
pop %ebx
pop %eax
mov %bl, interrupt_nr
push %ecx

lidt idtr

mov $0x20, %bx
call bx_to_segm

ljmp $0x18, $1f
1:
.code16

sti

mov %cr0, %ebx
dec %ebx
mov %ebx, %cr0

ljmp $0x0, $1f
1:

mov $0x0, %bx
call bx_to_segm

xor %dx, %dx
inc %dx
mov (%eax, %edx, 2), %bx
inc %dx
mov (%eax, %edx, 2), %cx
inc %dx
mov (%eax, %edx, 2), %dx
push %ebp
push %eax
mov (%eax), %ax

// self modifying int
.byte 0xcd
interrupt_nr:
.byte 0x0

pop %ebp
mov %ax, (%ebp)
mov %bx, 2(%ebp)
mov %cx, 4(%ebp)
inc %ebp
inc %ebp
mov %dx, 4(%ebp)
pop %ebp

nop
nop

lgdt gdtr
smsw %bx
or $1, %bx
lmsw %bx

ljmp $0x8, $1f
1:
.code32

cli

mov $0x10, %bx

.global bx_to_segm
bx_to_segm:

mov %bx, %ds
mov %bx, %es
mov %bx, %fs
mov %bx, %gs
mov %bx, %ss

ret
