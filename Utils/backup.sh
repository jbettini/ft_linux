#!/bin/bash

TXT_RED="\033[1;31m"
TXT_GREEN="\033[1;32m"
TXT_YELLOW="\033[1;33m"
TXT_BLUE="\033[1;34m"
FANCY_RESET="\033[0m"

set -eu

print_color () {
    echo -e "$1$2$FANCY_RESET"
}

handle_error() {
    print_color "$TXT_RED" "Error: line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

if [ -z "$LFS" ]; then
    print_color "$TXT_RED" "Error: LFS variable is not set."
    exit 1
fi

read -p "Enter a name for your LFS system backup: " name

# Umount system
print_color "$TXT_BLUE" "Umounting LFS chroot"
mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}

pushd $LFS
  print_color "$TXT_BLUE" "Creating the backup..."
  tar -cJzpf $HOME/$name.tar.xz .
popd

print_color "$TXT_BLUE" "reset chroot..."
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

print_color "$TXT_GREEN" "Backup create here : $HOME/$name"
