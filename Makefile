TARGET = boot.bin
COMMON= -static -m32
ASFLAGS = $(COMMON) -ffreestanding -ggdb
CFLAGS = $(ASFLAGS) -Os -fno-stack-protector
LDFLAGS = $(COMMON) -nostdlib -Tlinker.ld -n -Wl,--build-id=none -nostartfiles

OBJS = boot.o data.o entry.o

boot.img:

boot: $(OBJS)

boot.bin: boot

%.bin:
	objcopy -O binary $^ $@

%.img: %.bin
	dd if=/dev/zero of=$@ bs=1024 count=1440
	dd if=$< of=$@ bs=1 count=512 conv=notrunc

clean:
	$(RM) boot.bin boot.img boot $(OBJS)
