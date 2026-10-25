all:
	clang -ffreestanding -fno-stack-protector -fno-pic -mno-red-zone \
		-mcmodel=kernel -O2 -c kernel.c -o kernel.o
	ld -nostdlib -static -T linker.lds -o maraOS.elf kernel.o
	mkdir -p iso/boot/limine
	cp maraOS.elf iso/boot/
	cp limine.cfg iso/boot/limine/
	cp limine/limine-bios.sys limine/limine-bios-cd.bin limine/limine-uefi-cd.bin iso/boot/limine/
	xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin -no-emul-boot \
		-boot-load-size 4 -boot-info-table \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso -o maraOS.iso
	limine/limine bios-install maraOS.iso

run: all
	qemu-system-x86_64 -cdrom maraOS.iso -m 512M

clean:
	rm -f kernel.o maraOS.elf maraOS.iso
	rm -rf iso
