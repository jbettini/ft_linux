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

## Installation 
```
git clone https://github.com/jbettini/ft_linux.git
```

##  Walkthrough

### Step 1 - Preparing the Host System 

#### Host System Requirements

Verify the dependencies and install the missing package:
```
bash version-check.sh
sudo apt-get install -y <missing package>
```
1.  Creating a New Partition 

To install LFS, create three partitions: main, swap, and boot, using cfdisk. Maybe u need to create a disk before as you want.
-   Launch cfdisk:
```
cfdisk /dev/<Your LFS disk>
```
Create Main Partition (20GB):
-   "New" → "Primary" → Size: 20G → Type: Linux
Create Swap Partition (2GB):
-   "New" → "Primary" → Size: 2G → Type: Linux swap / Solaris
Create Boot Partition (1M):
-   "New" → "Primary" → Size: 1M → Type: BIOS boot
Save and Quit:
-   Write changes, confirm with yes, then "Quit"

2. 