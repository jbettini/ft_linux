dd if=/dev/zero of=lfs.iso bs=1M count=20480 status=progress

cfdisk lfs.iso

losetup --partscan --find --show lfs.iso != losetup -d /dev/loop0


---
mkfs -v -t ext4 /dev/loop0p1
mkfs -v -t ext4 /dev/loop0p2
mkswap    /dev/loop0p3

---
set environnement var :

set -Ux LFS /mnt/lfs

OR

echo "export LFS=/mnt/lfs" >> ~/.bash_profile
echo "export LFS=/mnt/lfs" >> ~/.bashrc

---

mkdir -vp $LFS

mount -v -t ext4 /dev/loop0p2 $LFS
swapon -v /dev/loop0p3

edit /etc/fstab, add this :

/dev/loop0p2            /mnt/lfs        ext4            defaults        1       1
/dev/loop0p3            none            swap            sw              0       0

---
tar xvf lfs_backup.tar.gz

---

mount /dev/loop0p1 /mnt/lfs/boot

edit /etc/fstab, add this :
/dev/loop0p1            /mnt/lfs/boot   ext4            defaults        0       0

bash enter.sh

cd /sources/_default/linux-6.7.4

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.7.4-jbettini
cp -iv System.map /boot/System.map-6.7.4-jbettini
cp -iv .config /boot/config-6.7.4-jbettini
cp -r Documentation -T /usr/share/doc/linux-6.7.4

exit
---

mount --bind /dev /mnt/lfs/dev
mount --bind /dev/pts /mnt/lfs/dev/pts
mount -t proc /proc /mnt/lfs/proc
mount -t sysfs /sys /mnt/lfs/sys
mount -t tmpfs /run /mnt/lfs/run

# Begin /etc/fstab

# file system           mount-point             type            options             dump  fsck
#                                                                                               order

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

grub-install /dev/loop0

---
cat > /boot/grub/grub.cfg << "EOF"
# Début de /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_msdos
insmod ext2

# Définir la partition racine pour GRUB
set root=(hd0,msdos1)

menuentry 'Linux From Scratch' {
    # Charger le noyau Linux
    linux (hd0,msdos1)/vmlinuz-6.7.4-jbettini root=/dev/loop0p2 ro quiet
}
EOF
---

cat > /boot/grub/grub.cfg << "EOFose
# Début de /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_msdos

# Définir la partition racine pour GRUB
set root=(hd0,2)

menuentry 'Linux From Scratch' {
        linux (hd0,1)/vmlinuz-6.7.4-jbettini root=/dev/sda2 ro net,ifnames=0 quiet debug init=/sbin/init
}
EOF

----------------------------

mount /dev/sdb3 /mnt/lfs/boot

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.7.4-jbettini

cp -iv System.map /boot/System.map-6.7.4-jbettini

cp -iv .config /boot/config-6.7.4-jbettini

Installez la documentation du noyau Linux :

cp -r Documentation -T /usr/share/doc/linux-6.7.4

mount --bind /dev /mnt/lfs/dev
mount --bind /dev/pts /mnt/lfs/dev/pts
mount -t proc /proc /mnt/lfs/proc
mount -t sysfs /sys /mnt/lfs/sys
mount -t tmpfs /run /mnt/lfs/run

------------------------------------------------------------------------------------

###############################################################

################################################################

grub-install /dev/sdb

cat > /boot/grub/grub.cfg << "EOF"
# Début de /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2
set root=(hd0,gpt2)

menuentry "Linux From Scratch, Linux 6.7.4-lfs-12.1-Jbettini" {
        linux  /boot/vmlinuz-6.7.4-jbettini UUID=85d320b3-8c81-46bd-808c-7bd284fd006b ro
}
EOF




umount /mnt/lfs/dev/pts
umount /mnt/lfs/dev
umount /mnt/lfs/proc
umount /mnt/lfs/sys
umount /mnt/lfs/run




--------------------

mkdir -vp ~/iso_contents

7z x lfs.iso -o ~/iso_contents

cd ~/iso_contents

mkisofs -o ~/Desktop/new_image.iso -V "LFS" -J -R ~/iso_contents