TARGET = boot-floppy
KERNEL = k/k/k
SOURCE_FS ?= ./k/iso

CPPFLAGS = -DKERNEL_PATH=$(KERNEL)
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
	dd if=$< of=$@ bs=1 count=512 conv=notrunc
	dd if=$(KERNEL) of=$@ bs=1 seek=512  conv=notrunc

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
