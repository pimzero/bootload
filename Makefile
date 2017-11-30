TARGET = boot-floppy
KERNEL = k/k/k
KERNEL_PATH = k
SOURCE_FS ?= ./k/iso

CPPFLAGS = -DKERNEL_PATH=$(KERNEL_PATH)
COMMON = -static -m32 -ggdb
ASFLAGS = $(COMMON) -ffreestanding -fno-asynchronous-unwind-tables
CFLAGS = $(ASFLAGS) -Os -fno-stack-protector
LDFLAGS = $(COMMON) -nostdlib -Tlinker.ld -n -Wl,--build-id=none -nostartfiles

OBJS = boot.o data.o entry.o bios.o elf_loader.o

all: $(TARGET)-emu.iso

$(TARGET): $(TARGET).o $(OBJS)

$(SOURCE_FS):
	$(MAKE) -C k

$(KERNEL):
	$(MAKE) -C k

%.bin: %
	objcopy -O binary $^ $@

%.img: %.bin $(KERNEL)
	dd if=/dev/zero of=$@ bs=1024 count=1440
	mkfs.fat -f1 -R1 -F16 $@
	mcopy -i $@ $(KERNEL) "::$(KERNEL_PATH)"
	dd if=$< of=$@ bs=1 count=448 seek=62 conv=notrunc

%-emu.iso: %.img $(SOURCE_FS)
	xorriso -as mkisofs -U -b $< -o $@ $^

%.iso: %.bin $(SOURCE_FS)
	xorriso -as mkisofs -U -no-emul-boot -b $< -o $@ $^

run-img-%: %.img
	qemu-system-i386 -fda $^ $(QEMU_FLAGS)

run-iso-%: %.iso
	qemu-system-i386 -cdrom $^ $(QEMU_FLAGS)

run-iso-emu-%: %-emu.iso
	qemu-system-i386 -cdrom $^ $(QEMU_FLAGS)

kvm-%: QEMU_FLAGS = -enable-kvm
kvm-%: run-%
	#

dbg-%: QEMU_FLAGS = -s -S
dbg-%: run-%
	#

clean:
	$(RM) -f $(OBJS) $(TARGET).o $(TARGET) $(TARGET).bin $(TARGET).img $(TARGET).iso $(TARGET)-emu.iso
	$(MAKE) -C k clean

.PHONY: all clean
