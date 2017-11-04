TARGET = boot.bin
TARGET_IMG = boot.img
COMMON= -static -m32
ASFLAGS = $(COMMON) -ffreestanding -ggdb
CFLAGS = $(ASFLAGS) -Os -fno-stack-protector
LDFLAGS = $(COMMON) -nostdlib -Tlinker.ld -n -Wl,--build-id=none -nostartfiles

OBJS = boot.o data.o entry.o bios.o

$(TARGET_IMG):

boot: $(OBJS)

boot.bin: boot

%.bin:
	objcopy -O binary $^ $@

%.img: %.bin
	dd if=/dev/zero of=$@ bs=1024 count=1440
	dd if=$< of=$@ bs=1 count=512 conv=notrunc

run: $(TARGET_IMG)
	qemu-system-i386 -fda $^ $(QEMU_FLAGS)

run-kvm: QEMU_FLAGS = -enable-kvm
run-kvm: run

clean:
	$(RM) boot.bin boot.img boot $(OBJS)

.PHONY: run run-kvm clean
