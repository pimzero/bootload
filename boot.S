.text
.code16
.global __entry
.global bx_to_segm
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

mov $0x10, %bx

call bx_to_segm

call __entry
