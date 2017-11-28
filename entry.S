#define ELF_e_ident 0
#define ELF_e_type (ELF_e_ident + 16 * 1)
#define ELF_e_machine (ELF_e_type + 2)
#define ELF_e_version (ELF_e_machine + 2)
#define ELF_e_entry (ELF_e_version + 4)
#define ELF_e_phoff (ELF_e_entry + 4)
#define ELF_e_shoff (ELF_e_phoff + 4)
#define ELF_e_flags (ELF_e_shoff + 4)
#define ELF_e_ehsize (ELF_e_flags + 4)
#define ELF_e_phentsize (ELF_e_ehsize + 2)
#define ELF_e_phnum (ELF_e_phentsize + 2)

#define ELF_p_type 0
#define ELF_p_offset (ELF_p_type + 4)
#define ELF_p_vaddr (ELF_p_offset + 4)
#define ELF_p_paddr (ELF_p_vaddr + 4)
#define ELF_p_filesz (ELF_p_paddr + 4)
#define ELF_p_memsz (ELF_p_filesz + 4)
#define ELF_p_flags (ELF_p_memsz + 4)
#define ELF_p_align (ELF_p_flags + 4)

#define PT_LOAD 1

.global __entry

__entry:

sub $0x808, %esp

lea 8(%esp), %ebx
mov $0x204, %eax
mov $2, %ecx
xor %edx, %edx
mov $0x13, %ebp
call bios_int

lea 8(%esp), %edx

/* Elf Loading */
/* EDX == begining of file */
cmpl $0x464C457f /* 0x7F"ELF" */, (%edx)
jne fail

xor %ecx, %ecx
mov (ELF_e_phnum)(%edx), %cx
mov %edx, %ebx
add (ELF_e_phoff)(%edx), %ebx
//mov (%ebx, %eax, 1), %ecx
//test %ecx, PT_LOAD

load_segment:

dec %ecx

sal $5, %ecx

cmp $PT_LOAD, (%ebx, %ecx)
jne noload

/* Segment PT_LOAD: loading */

push %ecx

mov (ELF_p_offset)(%ebx, %ecx), %esi
add %edx, %esi
mov (ELF_p_vaddr)(%ebx, %ecx), %edi
mov (ELF_p_filesz)(%ebx, %ecx), %ecx

rep movsb

pop %ecx

mov $0x0e43, %ax
mov $0x10, %ebp
call bios_int

noload:

shr $5, %ecx

inc %ecx

loop load_segment

mov (ELF_e_entry)(%edx), %eax

/* Elf loading end */

add $0x808, %esp
jmp *%eax

mov $0x0e41, %ax
mov $0x10, %ebp
call bios_int
1:

jmp 1b

fail:
mov $0x0e42, %ax
mov $0x10, %ebp
call bios_int

1:
jmp 1b
