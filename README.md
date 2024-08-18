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

It is highly recommended to do this project in a Virtual Machine with the same CPU as the PC that will submit the project and 50GB of disk space. Taking a snapshot is an easy way to save your progress throughout the project.

### Installation 

Clone the repository:
```
git clone https://github.com/jbettini/Ft_linux.git
cd Ft_linux
bash make_workdir.sh
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
#####  2.  Creating a Disk image and Partition

First we need to create an iso :
```
dd if=/dev/zero of=lfs.iso bs=1M count=20480 status=progress
```

To install LFS, create three partitions: main, swap, and boot, using cfdisk. Maybe u need to create a disk before, as you want.
-   Launch cfdisk:
```
cfdisk /path/to/your/iso
```
Select DOS:
    Create Partition :
    ```
        -   "New" → "Primary" → Size: 1M → Type: 83 Linux  -> Select Bootable
        Create Boot Partition (1M):
        -   "New" → "Primary" → Size: 18G → Type: 83 Linux
        Create Root Partition (18G)
        -   "New" → "Primary" → Size: 2G → Type: Linux swap / Solaris
        Create Swap Partition (2GB):
        Save and Quit:
        -   Write changes, confirm with yes, then "Quit"
    ```
Configure your ISO image as a loop device and access its partitions, use the following command:
```
losetup --partscan --find --show lfs.iso
```
-----------------------------------
##### 3. Prepare The System

This section outlines the script's actions to set up the system:

-   Create Filesystem and Mount Partitions:
    -   Initializes and mounts the necessary filesystems.
-   Create User lfs:
    -   Creates the user lfs for managing the build environment.
-   Download Required Packages:
    -   Downloads all necessary packages for the build process.
    -   If any package download fails due to a broken link, it must be downloaded manually. The script will notify you of any such issues.
-   Check for Broken Links:
    -   Verifies that all downloaded packages are correctly linked and available.
Run the script as root with:
```
bash prepare_system.sh
```
This will prepare the system for the subsequent steps.

User lfs is ready connect to it :
```
su - lfs;
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
Navigate to the Sources Directory:
```
cd /mnt/lfs/sources
```
For Each Package:
-   Extract using tar:
```
tar xvf package-name.tar.xz
```
-   Use pushd/cd to enter the extracted package directory.
-   Build the package with the specific instructions from LFS.
-   Use popd or cd .. to return to /mnt/lfs/sources.
-   Clean up with :
```
rm -rf package-name
```

##### 2. Compiling and Building Cross Tools

For this part, connect to lfs user and execute this script and wait:
```
su - lfs
sh install_cross_tools.sh
```

##### 3. Prepare and configure chroot

*Definition of chroot*

`chroot`, short for "change root," is a Unix system operation that changes the apparent root directory for a running process and its children. This creates an isolated environment where the process cannot access files outside the designated directory tree. It is commonly used for creating a contained development environment, testing software, or improving security by limiting the access of certain processes to a specific subset of the file system.

-   Disconnect from lfs user and connect to root :
```
"su - " OR "CTRL + D"
```
Now we need to prepare our chroot by executing the following script:
```
prepare_chroot.sh
```
This script sets up the chroot environment by:
-   Root Check: Ensures the script is run as root.
-   Permissions: Grants necessary permissions to chroot directories.
-   Mounting: Mounts required filesystems into the chroot.
-   Configure /dev/null: Creates a special /dev/null file within the chroot.
-   Copy: Copies the final configuration script into the chroot.

Execute the script with:
```
bash prepare_chroot.sh
```
Final Steps :
-   Enter the chroot environment and run the final installation and configuration scripts:
```
bash enterInChroot.sh
./last_settings.sh
```

##### 4a. Saving current state

At this part u can save the current state of your project, if u are using a virtual machine just take a snapshot otherwise follow this instructions :

-   Return to the root Home and execute the script ./Utils/save_state.sh :
```
bash save_state.sh
```
What the Script Does:
-   The script will:
    -   Unmount the LFS filesystem.
    -   Create an archive of all the files in the current environment.
    -   Remount all necessary filesystems to restore the environment.


##### 4b. Restore the system state

If u are using a virtual machine just restore from a snapshot, if u follow the instruction in II.4a chapter just do this:

```
rm -rf $LFS/*
cd $LFS
tar -xpf $HOME/backup_lfs_systemd.tar.xz
```
### III. Building the LFS System

#### Troubleshooting

    If you encounter errors during script execution: Check the line where the script stopped. Comment out all packages before this point and try installing them manually.
    If installation fails despite following these steps: Ensure you haven’t missed any previous steps.

##### 1. Installing All Packages

In this chapter, we begin the actual construction of the LFS system. To minimize errors, we provide detailed instructions for each package, even though some installation instructions might be shorter and more generic.
Installing All Packages

Ensure you are root and inside the chroot environment:
```
su -
sh enterInChroot.sh
```
Run the package installation script. Note that you need to select your timezone when installing Glibc. After the first script finishes, execute the second script manually:
```
bash package.sh
```
    First part of package installation completed. Now, execute the second script:
```
    bash package2.sh
```













































### IV. Last settings

#### 1. Set boot partition

-   First we need to mount our /boot partition :

```
mount /dev/loop0p1 /mnt/lfs/boot
```
-   Edit /etc/fstab, add this :
```
/dev/loop0p1            /mnt/lfs/boot   ext4            defaults        0       0
```
-   Reload systemd :
```
systemctl daemon-reload
```

#### 2. Compile Linux

-   Now we need to compile the linux kernel :
```
cd /sources
tar xvf linux-6.7.4.tar.xz && cd linux-6.7.4
```
-   Follow this steps to configure linux settings :
```
https://www.linuxfromscratch.org/lfs/view/systemd/chapter10/kernel.html
```
-   When linux is compiled use this commands:
```
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.7.4
cp -iv System.map /boot/System.map-6.7.4
cp -iv .config /boot/config-6.7.4
cp -r Documentation -T /usr/share/doc/linux-6.7.4
```

#### 3. Configure Boot Loader

-   Mount all partition, and enter in chroot :
```
bash mount.sh
bash enterInChroot.sh
```

-   Ensure your /etc/fstab looks like this to properly mount file systems: :
```
# Begin /etc/fstab

# file system           mount-point             type            options             dump  fsck
#                                                                                               order

/dev/loop0p1            /boot                   ext4            defaults            0     0
/dev/loop0p2            /                       ext4            defaults            1     1
/dev/loop0p3            swap                    swap            pri=1               0     0

proc                    /proc                   proc            nosuid,noexec,nodev 0     0
sysfs                   /sys                    sysfs           nosuid,noexec,nodev 0     0
devpts                  /dev/pts                devpts          gid=5,mode=620      0     0
tmpfs                   /run                    tmpfs           defaults            0     0
devtmpfs                /dev                    devtmpfs        mode=0755,nosuid    0     0
tmpfs                   /dev/shm                tmpfs           nosuid,nodev        0     0
cgroup2                 /sys/fs/cgroup          cgroup2         nosuid,noexec,nodev 0     0

# End /etc/fstab
```

-   Install grub :
```
grub-install /dev/loop0
```
-   Configure Grub :
```
cat > /boot/grub/grub.cfg << "EOF"
set default=0
set timeout=5

insmod part_msdos
insmod ext2

set root=(hd0,msdos1)

menuentry 'Linux From Scratch' {
    linux (hd0,msdos1)/vmlinuz-6.7.4 root=/dev/loop0p2 ro quiet
}
EOF
```

#### 3b. Recommendation, more package before Boot

-   We recommend downloading a few additional packages and their dependencies before booting the system. 
```
make-ca 1.14 
curl 8.6.0     
dhcpcd 10.0.8      
gnutls 3.8.6  
openssh
```
-   Check in BLS to have all dependencies and link :
```
https://www.linuxfromscratch.org/blfs/view/svn/
```

#### 4. Booting and network settings

First if u are in a Virtual Machine you need to get your iso inside your host, we recommend to use scp using openssh.

-   To boot, just edit the path of your iso on the script and execute it:
```
bash start_macOS

    OR

bash start_linux
```

-   Now if everything is ok, we need to configure internet follow this instruction :

-   Get the internet interface :
```
ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
3: sit0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/sit 0.0.0.0 brd 0.0.0.0
```
Is maybe something like eth0 or enp0s2.

-   Create the file :
```
cat > /etc/systemd/network/<interface name>.network << EOF
[Match]
Name=<interface name>

[Network]
DHCP=yes

[DHCPv4]
UseDomains=true
EOF
```
-   Enable the necessary services:
```
systemctl enable systemd-networkd
systemctl enable systemd-resolved
```
-   Create the symbolic link for DNS resolution:
```
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```
-   Start the services:
```
systemctl start systemd-networkd
systemctl start systemd-resolved
```

### V. Appendices 

By following this guide, you have built a minimal Linux system using LFS. To further enhance your system, refer to the BLFS book for additional packages and configurations.

If you need to download packages, use curl or wget. If these are unavailable, mount the ISO and download packages on a host system. Enter inside chroot, extract the archives, cd to the extracted directory, follow the BLFS instructions, and then delete the directory to keep your system clean. This will ensure a comprehensive and fully functional Linux environment.
Happy building!