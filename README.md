# ft_linux
## Overview

ft_linux is a project aimed at building a minimal Linux distribution from scratch. The project involves compiling and configuring various components and packages necessary to create a functioning Linux system.
## Features

-   Building a custom Linux kernel.
-   Setting up a minimal root filesystem.
-   Compiling essential tools and utilities.
-   Configuration of bootloader and startup scripts.

## Prerequisites

-   A Linux operating system.
-   GCC (GNU Compiler Collection) and other build tools installed.
-   Basic knowledge of Linux system administration and compiling software from source.
-   

##  Walkthrough

Make sure to use the LFS (Linux From Scratch) book alongside this README for a better understanding of each step:

English Version :
```
https://www.linuxfromscratch.org/lfs/view/stable/index.html
```
French Version :
```
http://fr.linuxfromscratch.org/view/lfs-systemd-stable/index.html
```

It is highly recommended to do this project in a Virtual Machine with a minimum of 4 cores and 50GB of disk space. Taking a snapshot is an easy way to save your progress throughout the project.

### Installation 

Clone the repository:
```
git clone https://github.com/jbettini/ft_linux.git
```
This repository contains essential files/scripts required for the installation and setup process.

When using a script, ensure you retrieve it from the appropriate directory. For example, if you are reading Part-<current-part>.

-----------------------------------
### I. Preparing the Host System

-----------------------------------
##### 1.  Dependencies

Verify the dependencies using the <version-check.sh> script inside the repository, and install missing package:
```
bash version-check.sh
sudo apt-get install -y <missing package>
```

-----------------------------------
#####  2.  Creating a New Partition 

To install LFS, create three partitions: main, swap, and boot, using cfdisk. Maybe u need to create a disk before, as you want.
-   Launch cfdisk:
```
cfdisk /dev/<Your LFS disk>
```
Create Partition :
-   "New" → "Primary" → Size: 20G → Type: Linux
Create Swap Partition (2GB):
-   "New" → "Primary" → Size: 2G → Type: Linux swap / Solaris
Create Boot Partition (1M):
-   "New" → "Primary" → Size: 1M → Type: BIOS boot
Save and Quit:
-   Write changes, confirm with yes, then "Quit"

-----------------------------------
##### 3.  Create File Systems

Main Partition:
```
mkfs -v -t ext4 /dev/sdb1
```
SWAP Partition:
```
mkswap /dev/sdb2
```
Boot Partition:
```
mkfs -v -t ext2 /dev/sdb3
```
-----------------------------------
##### 4.  Set the Environment

For Fish Shell:
```
set -Ux LFS /mnt/lfs
```
For Bash Shell:
```
echo "export LFS=/mnt/lfs" >> ~/.bash_profile
echo "export LFS=/mnt/lfs" >> ~/.bashrc
source ~/.bashrc
source ~/.bash_profile
```
Verify:
```
echo $LFS
```
Ensure it outputs /mnt/lfs.

-----------------------------------
##### 5. Mount the Partitions

Create Mount Point:
```
mkdir -pv $LFS
```
Mount Main Partition:
```
mount -v -t ext4 /dev/sdb1 $LFS
```
Enable Swap Partition:
```
swapon -v /dev/sdb2
```
Optionally, add to /etc/fstab:
```
/dev/sdb2        none   swap     0       0
```
The boot partition is typically mounted later during the bootloader installation process. For now, ensure the main partition and swap are set up and ready for the LFS build.

-----------------------------------
##### 6. Download Packages

Create Sources Directory:
```
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
```
Copy the file md5sums in $LFS/sources. Download with wget, use the wget-list files present in the repository as inputfile, and check if everything is downloaded with check_dl_package:
```
wget --input-file=wget-list-systemd --continue --directory-prefix=$LFS/sources;
wget --input-file=wget-list-patch --continue --directory-prefix=$LFS/sources;
bash check_dl_package.
```
Now just set the folders and the user lfs, execute these scripts:
```
bash build_folder.sh;
bash set_user.sh
```
-----------------------------------
##### 7. Set LFS users env

Connect to the user lfs and execute the script set_userLfs_env.sh
```
su - lfs;
bash set_userLfs_env.sh
```
-----------------------------------

### II. Building LFS Cross-Tools and Temporary Tools

##### Intro

In this section, we will cover the construction of cross-compilation tools and temporary tools necessary for building a Linux From Scratch (LFS) system. These tools are built in a controlled environment to ensure that the LFS system is built in a consistent and reproducible manner.

##### Understanding Cross Compiling

Before proceeding, it is highly recommended to understand how cross-compiling works, particularly the Canadian Cross model, which is a three-stage process to build cross-compilation tools. This knowledge is essential for troubleshooting and ensuring a successful build.

*Definition of Cross-Compilation*

Cross-compilation is the process of building executable code for a platform different from the one on which the compiler is running. This is essential when developing software for embedded systems or different architectures. For example, compiling code on a Linux machine to run on an ARM-based device. Understanding cross-compilation helps in setting up the correct toolchain and ensures that the resulting binaries are compatible with the target environment.

-----------------------------------
##### 1. How Scripts Work

Follow this process unless otherwise instructed. Summary of the build process:
Prepare Sources:
-   Place all sources and patches in /mnt/lfs/sources/.
Connect to the user lfs:
```
su - lfs
```
Navigate to the Sources Directory:
```
cd /mnt/lfs/sources
```
For Each Package:
-   Extract using tar:
```
tar xvf package-name.tar.xz
```
-   Use pushd to enter the extracted package directory.
-   Build the package with the specific instructions from LFS.
-   Use popd to return to /mnt/lfs/sources.
-   Clean up:
```
rm -rf package-name
```
##### 2. Compiling and Building Cross Tools

For this part, just execute the first script and wait:
```
sh cross_pk1.sh
```
If something occurs, check if you missed something before. Otherwise, just execute the second script and wait:
```
sh cross_pk2.sh
```

##### 3. Prepare and configure chroot

*Definition of chroot*

`chroot`, short for "change root," is a Unix system operation that changes the apparent root directory for a running process and its children. This creates an isolated environment where the process cannot access files outside the designated directory tree. It is commonly used for creating a contained development environment, testing software, or improving security by limiting the access of certain processes to a specific subset of the file system.

-   First disconnect from lfs user and connect to root :
```
su -
```
-   Execute the script `giveRightToRoot.sh' :
```
bash    giveRightToRoot.sh
```
-   Mount the chroot environnement :
```
bash mountChroot.sh
```
-   Configure /dev/null :
```
sudo rm -f /mnt/lfs/dev/null
sudo mknod -m 666 /mnt/lfs/dev/null c 1 3
ls -l /mnt/lfs/dev/null
```

-   Enter in chroot environnement :
```
bash enterInChroot.sh
```
-   Now we need to set the environment :
```
cat >> setChrootEnv.sh << EOF

mkdir -pv /{boot,home,mnt,opt,srv}
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}
ln -sfv /run /var/run
ln -sfv /run/lock /var/lock
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

EOF
```

-   After this we need to create all the essential file and symbolic link, copy paste this commands :

```
ln -sv /proc/self/mounts /etc/mtab
```
```
cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF
```
```
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/usr/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/usr/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/usr/bin/false
systemd-network:x:76:76:systemd Network Management:/:/usr/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/usr/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/usr/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
systemd-oom:x:81:81:systemd Out Of Memory Daemon:/:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF
```
```
cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
kvm:x:61:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
uuidd:x:80:
systemd-oom:x:81:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF
```
```
echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester
exec /usr/bin/bash --login
```
```
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp
```

-   Last Step for this part is to install the following tools just cpoy paste the content of cross_pk3.sh in the midlle of the command :

```
cat >> cross_pk3.sh << EOF

...
<Copy paste the content of cross_pk3.sh>
...

EOF
```
```
bash cross_pk3.sh
```
-   Just wait the installation of all and use :
```
rm -rf cross_pk3.sh
```

##### 4a. Saving current state

At this part u can save the current state of your project, if u are using a virtual machine just take a snapshot otherwise follow this instructions :

-   Quit the chroot environemment :
```
exit
```
-   Unmount the virtual file system :
```
mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}
```
-   Create an achive of the current state:
```
cd $LFS
tar -cJpf $HOME/lfs-temp-tools-12.1-systemd.tar.xz .
```

##### 4b. Restore the system state

If u are using a virtual machine just restore from a snapshot, if u follow the instruction in II.4a chapter just do this:

```
cd $LFS
rm -rf ./*
tar -xpf $HOME/lfs-temp-tools-12.1-systemd.tar.xz
```


### III. Construction of the LFS system

In this chapter, we begin the actual construction of the LFS system. We are now at the final stage of project. Although installation instructions could often be shorter and more generic, we provide complete instructions for each package to minimize errors.

##### 1. Installation of all packages

-   First connect to root, and copy the script package.sh inside chroot:
```
su -
cp -f package.sh /mnt/lfs/.
```

-   Then enter in chroot:
```
sh enterInChroot.sh
```
-   Start the package installation script:
```
bash package.sh
```


