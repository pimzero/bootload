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

#define ELF_sizeof_Phdr 32

#define PT_LOAD 1

.global loader_elf
loader_elf:
/* Elf Loading */
driver_elf_begin:

/* EDX == begining of file */
cmpl $0x464C457f /* 0x7F"ELF" */, (%edx)
jne panic

xor %ecx, %ecx
mov (ELF_e_phnum)(%edx), %cx
mov %edx, %ebx
add (ELF_e_phoff)(%edx), %ebx
//mov (%ebx, %eax, 1), %ecx
//test %ecx, PT_LOAD

// Need at least 1 segment (underflow if 0 segment)
// TODO: Check if 0 segments
load_segment:

sal $5, %ecx /* ecx *- ELF_sizeof_Phdr */

cmp $PT_LOAD, (- ELF_sizeof_Phdr)(%ebx, %ecx)
jne noload

/* Segment PT_LOAD: loading */

push %ecx

mov (ELF_p_offset - ELF_sizeof_Phdr)(%ebx, %ecx), %esi
add %edx, %esi
mov (ELF_p_vaddr - ELF_sizeof_Phdr)(%ebx, %ecx), %edi
mov (ELF_p_memsz - ELF_sizeof_Phdr)(%ebx, %ecx), %eax
mov (ELF_p_filesz - ELF_sizeof_Phdr)(%ebx, %ecx), %ecx
// TODO: if %ecx > %eax -> %ecx = %eax
sub %ecx, %eax

rep movsb

xchg %ecx, %eax
rep stosb

pop %ecx

noload: // Don't do anything

shr $5, %ecx
loop load_segment

mov (ELF_e_entry)(%edx), %eax

driver_elf_end:
ret
/* Elf loading end */
