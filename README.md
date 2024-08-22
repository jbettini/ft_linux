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
cd Workdir
```
This repository contains essential files/scripts required for the installation and setup process.

When using a script, ensure you retrieve it from the appropriate directory. For example, if you are reading Part-<current-part>. Otherwise, all necessary scripts for both the host and the chroot environments are available in the /Workdir subdirectory.

-----------------------------------
### I. Preparing the Host System

-----------------------------------
##### 1.  Dependencies

Verify the dependencies using the <version-check.sh> script inside the repository, and install missing package:
```
bash version-check.sh
sudo apt-get install -y <missing package>
```
Wget is neccesary too, ensure is installed in your system.

Create all the workdirectory with :
```
bash make_workdir.sh
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
        -   "New" → "Primary" → Size: 1G → Type: 83 Linux  -> Select Bootable
        Create Boot Partition (1M):
        -   "New" → "Primary" → Size: 18G → Type: 83 Linux
        Create Root Partition (18G)
        -   "New" → "Primary" → Size: 1G → Type: Linux swap / Solaris
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
bash prepare_chroot.sh
```
This script sets up the chroot environment by:
-   Root Check: Ensures the script is run as root.
-   Permissions: Grants necessary permissions to chroot directories.
-   Mounting: Mounts required filesystems into the chroot.
-   Configure /dev/null: Creates a special /dev/null file within the chroot.
-   Copy: Copies the final configuration script into the chroot.

Final Steps :
-   Enter the chroot environment and run the final installation and configuration scripts:
```
bash enterInChroot.sh
./last_settings.sh
```

##### 4a. Saving current state

At this part u can save the current state of your project, if u are using a virtual machine just take a snapshot otherwise follow this instructions :

-   Return to the root Home and execute the script Ft_linux/Utils/backup.sh:
```
bash backup.sh
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
cd /Workdir
```
Run the package installation script. Note that you need to select your timezone when installing Glibc. After the first script finishes, execute the second script manually:
```
    bash package.sh
```
First part of package installation completed. Now, execute the second script:
```
    bash package2.sh
```
###### Falcutative
After the full this script it is highly recommended to create a backup, return to the root host home and execute the script Ft_linux/Utils/backup.sh:
```
bash backup.sh
```
You can save up to 2 GB by removing non-essential debugging symbols. A backup is recommended to avoid making the system unusable in case of an error, if u want to clean-up just execute this script inside your chroot Workdir :
```
bash clean.sh
```

##### 1b. Additional Package Installation

If you want to enhance your LFS system with more functionality, you can install additional packages after completing the initial steps. Here are some useful suggestions:

-   curl: A command-line tool for transferring data with URLs.
-   git: A distributed version control system.
-   openssh: A suite of tools for securely accessing remote machines.

To install these packages, you will need to download them first, execute this script, inside your host machine :
```
    bash dl_blfs_pkg.sh
```

### IV. Last settings

#### 1. Prepare for booting

For this part, inside your chroot Workdir execute the script prepare_boot.sh :
```
bash prepare_boot.sh
```

#### 2. Booting and network settings

First if u are in a Virtual Machine you need to get your iso inside your host, we recommend to use scp or nc.

-   To boot, just edit the path of your iso on the script and execute it:
```
bash qemu_start_macOS

    OR

bash qemu_start_linux
```

-   Now if everything is ok, we need to configure internet follow this instruction :
    -   A script is normally available inside your system there "/Workdir/get_internet.sh" just execute it :
    ```
    bash /Workdir/get_internet.sh
    ```
    - if you choose before to enchance your Linux, now you need to install the downloaded package for this a script is another time available :
    ```
    bash /Workdir/install_blfs.sh
    ```
### V. Appendices 

By following this guide, you have built a Linux system using LFS. To further enhance your system, refer to the BLFS book for additional packages and configurations.

If you need to download more packages, use curl or wget. If these are unavailable, mount the ISO and download packages on a host system. Enter inside chroot, extract the archives, cd to the extracted directory, follow the BLFS instructions, and then delete the directory to keep your system clean. This will ensure a comprehensive and fully functional Linux environment.
Happy building!