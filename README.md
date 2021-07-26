# physix-on-usb

## Why does this exist? ##
The purpose of this repo is to maintain and document the process
of building a bootable Physix Project OS on USB. This project 
specifically is tailored to Physix Project Linux (physixproject.org),
but these instructions should be general enough to apply to most use cases.


## Build ISO Image Process##
0. Create SquashFS Image
1. Comfig/compile kernel
2. Edit build-iso.conf
     - Define paths where the kernel, initrd,and filesystem are found.
3. Run: ./build-iso.sh


## Create SquashFS Image ##
```
mkdir physix_root
mount /dev/mapper/physix-root  physix_root
mount /dev/mapper/physix-home  physix_root/home
mount /dev/mapper/physix-var   physix_root/var
mount /dev/mapper/physix-admin physix_root/opt/admin
mksquashfs physix_root filesystem.squashfs
```

##  Comfig/compile kernel ##
```
git clone git://github.com/sfjro/aufs5-standalone.git
cd aufs5-standalone
git checkout aufs5.4.3
cp aufs5-*.patch ..
rm -f include/uapi/linux/Kbuild
tar cvfz aufs5.tar.gz Documentation fs include
cp aufs5.tar.gz ..
cd ..

wget wget https://physixproject.org/source/base/linux-5.4.41.tar.xz
tar xf linux-5.4.41.tar.xz
cd linux-5.4.41
cp /path/to/physix-on-usb/config-linux-5.4.41 .
cat ../aufs5-base.patch | patch -Np1
cat ../aufs5-kbuild.patch | patch -Np1
cat ../aufs5-mmap.patch | patch -Np1
cat ../aufs5-standalone.patch | patch -Np1
tar xvf ../aufs5.tar.gz
```

When configuring the kernel, make sure the following are enabled as builtins (not as modules):
* SQUASHFS support (and support for SQUASHFS XZ compressed file systems).
* UNIONFS or AUFS support (Teo En Ming *did not* patch Linux Kernel
* AUFS or UNIONFS support
* CDROM support (ISO9660).
* DEVTMPFS support.
* OverlayFS support
* cgroups
If you built the kernel with the kernel config provided in this repo, 
these options should already be set.

```
make menuconfig

make -j8
make modules
make modules_install
make headers_install
```

Before creating the initramfs using the next command, there needs
to be some edits to how Systemd boots the system. On boot, initramfs
will mount the root of the ISO image (/dev/disk/by-label/Physix-Project).

We want to add a modified version of the 'initrd-switch-root.serivce' and 
'mount-squashfs.service' files. Copy them to /lib/systemd/system/. These 
unit files are responsible for mounting the squashfs filesystem under
/sysroot/live/filesystem.squashfs during the last stage of boot.
Add the paths of these unit files to be included in the initramfs by
editing /etc/dracut.conf with the following line: 
'install_items+="/lib/systemd/system/mount-squashfs.service"'

Run kinstall:
```
kinstall 5.4.41 Live-Kernel
```
You should have a kernel and an initrd located at /boot.


## build-iso.conf ##
Add paths to the kernel, initrd, and squash filesstem to the build-iso.conf file
located at root of this repo.


## Mount OverlayFS ##
OverlayFS provides a way to write to the filesystem (in memory).
Changes are not persistent between reboots.
```
mkdir /tmp/upper/
mkdir /tmp/workdir/
mkdir /tmp/overlay/
mount -t overlay -o lowerdir=/,upperdir=/tmp/upper/,workdir=/tmp/workdir/ none /tmp/overlay/
chroot /tmp/overlay/
```

## Troubleshooting ##
* Issue: Kernel boots, but switchroot fails.
* Solution: Mount it manually. This will require searching to figure out which device 
            the USB was assigned at boot. Usually it can be found under 
            /dev/disk/by-label/Physix-Project. Mount it. Then mount the squash filesystem
            over it and call switch_root.
```
mount /dev/disk/by-label/Physix-Project /sysroot
mount /sysroot/live/filesystem.squash /sysroot
systemctl --no-block switch-root /sysroot
```

