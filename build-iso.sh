#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2021 Tree Davies
source ./build-iso.conf

`which genisoimage`
if [ $? -ne 0 ] ; then
	echo "Error: Failed to find dependency - genisoimage"
	exit 1
fi

SL_URL='https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/Testing/6.04/syslinux-6.04-pre1.tar.gz'
SYSLINUX='./syslinux-6.04-pre1/bios'

if [ ! -r ./syslinux-6.04-pre1.tar.gz ] ; then
	wget $SL_URL
	tar xf syslinux-6.04-pre1.tar.gz
fi

cp -v $SYSLINUX/core/isolinux.bin                  ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/com32/hdt/hdt.c32                  ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/com32/elflink/ldlinux/ldlinux.c32  ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/com32/lib/libcom32.c32             ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/com32/gpllib/libgpl.c32            ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/com32/cmenu/libmenu/libmenu.c32    ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/com32/cmenu/libmenu/libmenu.c32    ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/com32/libutil/libutil.c32          ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/com32/menu/vesamenu.c32            ./physix-project-usb/isolinux/ &&
cp -v $SYSLINUX/memdisk/memdisk                    ./physix-project-usb/isolinux/ 
if [ $? -ne 0 ] ; then
	echo "Error: cp syslinux files"
	exit 1
fi

if [ $KERNEL ] ; then
	cp -v $KERNEL ./physix-project-usb/live/vmlinuz.x86_64
else
	echo "No exported KERNEL"
	exit 1
fi

if [ $INITRD ] ; then
    cp -v $INITRD ./physix-project-usb/live/initrd-img.x86_64
else
	echo "No exported INITRD"
	exit 1
fi

if [ $SQUASH_FS ] ; then
    cp -v $SQUASH_FS ./physix-project-usb/live/filesystem.squashfs
else
	echo "No exported SQUASH_FS"
	exit 1
fi

genisoimage -o "Physix-Project-Beta.iso" \
            -v -J -R -D   \
            -A "Physix-Project"   \
            -V Physix-Project   \
            -no-emul-boot \
            -boot-info-table \
            -boot-load-size 4   \
            -b isolinux/isolinux.bin  \
            -c isolinux/isolinux.boot physix-project-usb

$SYSLINUX/utils/isohybrid.pl  Physix-Project-Beta.iso



