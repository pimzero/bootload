TARGET = boot
COMMON= -static -m32
ASFLAGS = $(COMMON) -ffreestanding -fno-asynchronous-unwind-tables
CFLAGS = $(ASFLAGS) -Os -fno-stack-protector
LDFLAGS = $(COMMON) -nostdlib -Tlinker.ld -n -Wl,--build-id=none -nostartfiles

OBJS = boot.o data.o entry.o bios.o

SOURCE_ISO ?= source.iso

all: $(TARGET).iso

$(TARGET): $(OBJS)

%.bin: %
	objcopy -O binary $^ $@

%.img: %.bin
	dd if=/dev/zero of=$@ bs=1024 count=1440
	dd if=$< of=$@ bs=1 count=512 conv=notrunc

%.iso: %.bin $(SOURCE_ISO)
	cp $(SOURCE_ISO) $@
	dd if=$< of=$@ bs=1 count=512 conv=notrunc

run-iso: $(TARGET).iso
	qemu-system-i386 -fda $^ $(QEMU_FLAGS)
	#qemu-system-i386 -cdrom $^ $(QEMU_FLAGS)

run-img: $(TARGET).img
	qemu-system-i386 -fda $^ $(QEMU_FLAGS)

run-iso-kvm: QEMU_FLAGS = -enable-kvm
run-iso-kvm: run-iso

run-img-kvm: QEMU_FLAGS = -enable-kvm
run-img-kvm: run-img

clean:
	$(RM) boot.bin boot.img boot.iso boot $(OBJS)

.PHONY: all run-iso run-iso-kvm run-img run-img-kvm clean
