.section .driver, "ax"
#define FAT_bytes_per_sector 0xb
#define FAT_sectors_per_cluster 0xd
#define FAT_reserved_sectors 0xe
#define FAT_fat_copies 0x10
#define FAT_root_entries 0x11
#define FAT_sectors_per_fat 0x16
#define FAT_sectors_per_track 0x18

#define FAT_filename 0
#define FAT_filename_ext 0x8
#define FAT_file_attr 0xb
#define FAT_file_cluster 0x1a
#define FAT_file_sze 0x1c

.global floppy_driver
.global dev_driver
/* Noreturn */

floppy_driver:
dev_driver:
sub $0x208, %esp

lea 8(%esp), %ebx
push %ebx

/* Fat16 load root */

//mov $0x7c00, %ecx
xor %ecx, %ecx
mov $0x7c, %ch
mov FAT_fat_copies(%ecx), %al
cbw
imul FAT_sectors_per_fat(%ecx), %ax
add FAT_reserved_sectors(%ecx), %ax

push %eax
//dec %eax

call load_sector
/* TODO: Verify this */
//mov $13, %eax

pop %ecx // root_begin

pop %ebp
/* Root loaded starting at ebp */

/* TODO: iterate over root (and maybe subdirs) to find kernel */

mov FAT_file_sze(%ebp), %edi
neg %edi
lea (%ebp, %edi), %esp
neg %edi

ljmp $0x18, $1f
1:
.code16

//xor %edx, %edx
//xor %ebx, %ebx
//mov (0x7c00 + FAT_sectors_per_cluster), %bl
//divb %bx, %ax


mov FAT_file_cluster(%bp), %ax
mulb (0x7c00 + FAT_sectors_per_cluster)
mov %ax, %si
/* cx = root_begin, si = C * S/C */
mov (0x7c00 + FAT_root_entries), %ax
mov (0x7c00 + FAT_bytes_per_sector), %bx
shr $5, %bx
xor %dx, %dx
div %bx, %ax
/* ax = root_size = root_entries * 0x20 / bytes/sectors */

mov %sp, %bp

add %si, %ax
add %cx, %ax
dec %ax
dec %ax

//dec %ax

mov %bp, %bx

ljmp $0x8, $1f
1:
.code32
push %ebx

mov %edi, %ecx
shr $9, %ecx
inc %ecx

load_file:
push %ecx
push %ebx
push %eax
call load_sector
// add 512, ebx
pop %eax
inc %eax
pop %ebx
add $512, %ebx
pop %ecx
loop load_file

mov $0x0e44, %ax
mov $0x10, %ebp
call bios_int

pop %edx

call loader_elf

mov $0x00007BF0, %esp
jmp *%eax

load_sector:
/* ebx = buf, %eax = sector number */
xor %ecx, %ecx
mov $0x7c, %ch

mov FAT_sectors_per_track(%ecx), %cx
xor %edx, %edx
//dec %cx
div %cx, %ax
inc %edx

mov %edx, %ecx // Sector in cl

// Hardcoded handling of 2 heads
xor %edx, %edx
mov %al, %ch
mov %ch, %dh
and $1, %dh
shr %ch

mov $0x201, %eax
//mov $2, %ecx
mov $0x13, %ebp
call bios_int

ret
