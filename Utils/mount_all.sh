#!/bin/bash

losetup --partscan --find --show lfs.iso
mount -v -t ext4 /dev/loop0p2 /mnt/lfs
mount -v -t ext4 /dev/loop0p1 /mnt/lfs/boot
swapon -v /dev/loop0p3

sleep 5
mount -v --bind /dev $LFS/dev
mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi