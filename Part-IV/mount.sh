#!/bin/bash

mount --bind /dev /mnt/lfs/dev
mount --bind /dev/pts /mnt/lfs/dev/pts
mount -t proc /proc /mnt/lfs/proc
mount -t sysfs /sys /mnt/lfs/sys
mount -t tmpfs /run /mnt/lfs/run