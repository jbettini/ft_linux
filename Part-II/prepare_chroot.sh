#!/bin/bash

TXT_RED="\033[1;31m"
TXT_GREEN="\033[1;32m"
TXT_YELLOW="\033[1;33m"
TXT_BLUE="\033[1;34m"
FANCY_RESET="\033[0m"

print_color () {
    echo -e "$1$2$FANCY_RESET"
}

user=$(whoami)

if [ $user != "root" ]; then 
    echo -e "Please, Load this script with root\n"
    exit 1
fi

handle_error() {
    print_color "$TXT_RED" "Error: line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

set -eu

# Give Right to Root
print_color "$TXT_BLUE" "Giving the every neccesary right to root..."

chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -R root:root $LFS/lib64 ;;
esac

# Mount Chroot
print_color "$TXT_BLUE" "Mounting chroot..."

mkdir -pv $LFS/{dev,proc,sys,run}
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

print_color "$TXT_GREEN" "Chroot system is mounted."

# Configure /dev/null

print_color "$TXT_BLUE" "Settings /dev/null for chroot"
sudo rm -f /mnt/lfs/dev/null
sudo mknod -m 666 /mnt/lfs/dev/null c 1 3
ls -l /mnt/lfs/dev/null

print_color "$TXT_GREEN" "/dev/null is set."

chmod 777 ./last_settings.sh
cp -f ./last_settings.sh $LFS/.
cp -f ../Part-III/* $LFS/.
print_color "$TXT_YELLOW" "EveryThings is set now just, Follow the manual."