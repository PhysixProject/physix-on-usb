# physix-on-usb

The purpose of this repo is to maintain and document the process
of building a bootable Physix Project USB


## build-iso.conf ##
Add paths to the kernel, initrd, and squash filesstem to config file
located at root of this repo.
* If you have not built your kernel, see instructions below.
* If you have not created your SquashFS image, see section below.


## Build ISO image ##
0. Edit build-iso.conf
1. Run: ./build-iso.sh


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
* cgroups

```
make menuconfig

make -j8
make modules
make modules_install
make headers_install
kinstall 5.4.41 Live-Kernel
```

You should have a kernel and initrd located at /boot.


## Create SquashFS Image ##

mnt /dev/mapper/physix-root /some/dir
mksquashfs /some/dir dir.sqsh


## Troubleshooting ##
* Issue: Kernel boots, but switchroot fails.
* Solution: Mount it manually. This will require searching to figure out which device 
            the USB was assigned at boot. Mount it. then mount the squash filesystem
            over it and call switch_root.
```
mkdir -p /tmp/SR0
mount /dev/sr0 /tmp/SR0
if [ -e /tmp/SR0/live/filesystem.squashfs ] ; then
	mount /tmp/SR0/live/filesystem.squashfs /sysroot
	switchroot
fi
```

