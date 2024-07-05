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

##  Walkthrough

### I.  Preparing for the Build 

#### Installation 
Clone the repository:
```
git clone https://github.com/jbettini/ft_linux.git
```
This repository contains essential files/scripts required for the installation and setup process.

-----------------------------------
#### Step 1 - Preparing the Host System 

##### 1.  Dependencies

Verify the dependencies using the <version-check.sh> script inside the repository, and install missing package:
```
bash version-check.sh
sudo apt-get install -y <missing package>
```

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
#### Step 2 - Packages and Patches 

##### 1. Download Packages

Create Sources Directory:
```
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
```
Download with wget, use the wget-list file present in the repository as inputfile:
```
wget --input-file=wget-list-systemd --continue --directory-prefix=$LFS/sources
```