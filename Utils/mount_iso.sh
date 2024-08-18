#!/bin/bash

losetup --partscan --find --show lfs.iso
mount -v -t ext4 /dev/loop0p2 /mnt/lfs
swapon -v /dev/loop0p3