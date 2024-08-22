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

# Configuration Kernel

cd /sources

######################- LINUX -#########################

tar xvf linux-6.7.4.tar.xz

pushd linux-6.7.4
    make mrproper
    cp /Workdir/template.config /sources/linux-6.7.4/.config
    make
    make modules_install
    cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.7.4-lfs-12.1-systemd
    cp -iv System.map /boot/System.map-6.7.4
    cp -iv .config /boot/config-6.7.4
    cp -r Documentation -T /usr/share/doc/linux-6.7.4
    install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Début de /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# Fin de /etc/modprobe.d/usb.conf
EOF
popd

rm -rf linux-6.7.4

# Configuration inputrc & shells

cat > /etc/inputrc << "EOF"
# Début de /etc/inputrc
# Modifié par Chris Lynn <roryo@roryo.dynup.net>

# Permet à l'invite de commande de continuer sur la ligne suivante
set horizontal-scroll-mode Off

# Active l'entrée 8-bits
set meta-flag On
set input-meta On

# Désactive la suppression du 8ème bit
set convert-meta Off

# Garder le 8ème bit pour l'affichage
set output-meta On

# « none », « visible » ou « audible »
set bell-style none

# Toutes les indications qui suivent font correspondre la séquence
# d'échappement contenue dans le 1er argument à la fonction
"\eOd": backward-word
"\eOc": forward-word

# pour la console linux
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# pour xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# pour Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# Fin de /etc/inputrc
EOF

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# Fin de /etc/shells
EOF

# Configuration grub 

cat << EOF > /etc/fstab
# Begin /etc/fstab

# file system           mount-point             type            options             dump  fsck
#                                                                                               order

/dev/sda1               /boot                   ext4            defaults            0     0
/dev/sda2               /                       ext4            defaults            1     1
/dev/sda3               swap                    swap            pri=1               0     0

proc                    /proc                   proc            nosuid,noexec,nodev 0     0
sysfs                   /sys                    sysfs           nosuid,noexec,nodev 0     0
devpts                  /dev/pts                devpts          gid=5,mode=620      0     0
tmpfs                   /run                    tmpfs           defaults            0     0
devtmpfs                /dev                    devtmpfs        mode=0755,nosuid    0     0
tmpfs                   /dev/shm                tmpfs           nosuid,nodev        0     0
cgroup2                 /sys/fs/cgroup          cgroup2         nosuid,noexec,nodev 0     0

# End /etc/fstab
EOF

grub-install /dev/loop0

cat > /boot/grub/grub.cfg << "EOF"
set default=0
set timeout=5

insmod part_msdos
insmod ext2

set root=(hd0,msdos1)

menuentry 'Linux From Scratch' {
    linux (hd0,msdos1)/vmlinuz-6.7.4-lfs-12.1-systemd root=/dev/sda2 ro quiet
}
EOF