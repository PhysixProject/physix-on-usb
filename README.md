# physix-on-usb

The purpose of this repo is to maintain and document the process
of building a bootable Physix Project USB


## Config ##
Add paths to the kernel, initrd, and squash filesstem to config file
located at root of this repo.
* If you have not built your kernel, see instructions below.
* If you have not created your SquashFS image, see section below.


## Build ISO image ##
Run: ./build-iso.sh


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

wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.4.41.tar.gz
tar xf linux-5.4.41.tar.gz
cd linux-5.4.41
cp /opt/admin/physix/build-scripts/03-base-config/configs/linux_config-5.4.41 .
cat ../aufs5-base.patch | patch -Np1
cat ../aufs5-kbuild.patch | patch -Np1
cat ../aufs5-mmap.patch | patch -Np1
cat ../aufs5-standalone.patch | patch -Np1
tar xvf ../aufs5.tar.gz

make menuconfig
```
When you configure the kernel, make sure the following are enabled as builtins (not as modules):
* SQUASHFS support (and support for SQUASHFS XZ compressed file systems).
* UNIONFS or AUFS support (Teo En Ming *did not* patch Linux Kernel
* AUFS or UNIONFS support
* CDROM support (ISO9660).
* DEVTMPFS support.
* cgroups

```
make -j8
make modules
make modules_install
make headers_install
```

## Create SquashFS Image ##
TODO





## Troubleshooting ##
* Issue: Kernel boots, bu switchroot fails.
* Solution: Mount it manually.
```
mkdir -p /tmp/SR0
mount /dev/sr0 /tmp/SR0
if [ -e /tmp/SR0/live/filesystem.squashfs ] ; then
	mount /tmp/SR0/live/filesystem.squashfs /sysroot
fi
```

