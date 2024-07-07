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

### Installation 

Clone the repository:
```
git clone https://github.com/jbettini/ft_linux.git
```
This repository contains essential files/scripts required for the installation and setup process.

When using a script, ensure you retrieve it from the appropriate directory. For example, if you are reading Part-<current-part>.

-----------------------------------
### I. Preparing the Host System

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

##### 6. Download Packages

Create Sources Directory:
```
mkdir -v $LFS/sources $LFS/patch
chmod -v a+wt $LFS/sources $LFS/patch
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

##### 7. Set LFS users env

Connect to the user lfs and execute the script set_userLfs_env.sh
```
su - lfs;
bash set_userLfs_env.sh
```

### II. Building LFS Cross-Tools and Temporary Tools

##### Intro

In this section, we will cover the construction of cross-compilation tools and temporary tools necessary for building a Linux From Scratch (LFS) system. These tools are built in a controlled environment to ensure that the LFS system is built in a consistent and reproducible manner.

##### Understanding Cross Compiling

Before proceeding, it is highly recommended to understand how cross-compiling works, particularly the Canadian Cross model, which is a three-stage process to build cross-compilation tools. This knowledge is essential for troubleshooting and ensuring a successful build.

###### 1. Important

Follow this process unless otherwise instructed, Summary of the build process:

Prepare Sources:
    Place all sources and patches in /mnt/lfs/sources/.

Navigate to Sources Directory:
```
cd /mnt/lfs/sources
```
For Each Package:

-   Extract using tar:
```
tar -xf package-name.tar.xz
````
-   For the Build, Follow package-specific instructions.
-   Clean Up:
```
rm -rf package-name
```


