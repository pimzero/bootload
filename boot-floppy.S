#define FAT_bytes_per_sector 0xb
#define FAT_sectors_per_cluster 0xd
#define FAT_reserved_sectors 0xe
#define FAT_fat_copies 0x10
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

/* TODO: Verify this */
//mov $13, %eax
mov FAT_sectors_per_track(%ecx), %cx
xor %edx, %edx
dec %cx
div %cx, %ax
mov %al, %ch
mov %dl, %cl
inc %cx

mov $0x201, %eax
//mov $2, %ecx
xor %edx, %edx
mov $0x13, %ebp
call bios_int

pop %edx
/* Root loaded starting at edx */

/* TODO: iterate over root (and maybe subdirs) to find kernel */

mov FAT_file_sze(%edx), %ecx
mov FAT_file_cluster(%edx), %ax

ok:
jmp ok


mov $0x0e44, %ax
mov $0x10, %ebp
call bios_int


//pop %edx

call loader_elf

add $0x208, %esp
jmp *%eax
