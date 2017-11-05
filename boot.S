.text
.code16
.global __entry
.global bx_to_segm
.global go_pm

cli

#jmp 1f
#1:

# PM mode

call go_pm

.code32

mov $0x10, %bl

call bl_to_segm

call __entry
