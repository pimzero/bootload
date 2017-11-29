.section .boot, "ax"
.code16
.global __entry16
__entry16:

cli

call go_pm

.code32

mov $0x10, %bl

call bl_to_segm

push %edx

call __entry
