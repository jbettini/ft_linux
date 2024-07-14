
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

###############################################################
# Begin /etc/fstab
# file system   mount-point    type     options             dump  fsck order
UUID=f4742823-618a-47bc-a80a-8c1b532cf0fa      /               ext4     defaults            1     1
UUID=72e59a02-8543-4551-8dd9-084e0fd17c60      swap            swap     pri=1               0     0
UUID=6e210d01-1988-443a-b4d7-8cc35045c02b      /boot           ext2     defaults            0     0

proc            /proc          proc     nosuid,noexec,nodev 0     0
sysfs           /sys           sysfs    nosuid,noexec,nodev 0     0
devpts          /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs           /run           tmpfs    defaults            0     0
devtmpfs        /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs           /dev/shm       tmpfs    nosuid,nodev        0     0
# End /etc/fstab
################################################################

grub-install /dev/sdb

cat > /boot/grub/grub.cfg << "EOF"
# Début de /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2
set root=(hd1,gpt3)

menuentry "Linux From Scratch, Linux 6.7.4-lfs-12.1-Jbettini" {
        linux  /boot/vmlinuz-6.7.4-jbettini root=UUID=f4742823-618a-47bc-a80a-8c1b532cf0fa ro
}
EOF

umount /mnt/lfs/dev/pts
umount /mnt/lfs/dev
umount /mnt/lfs/proc
umount /mnt/lfs/sys
umount /mnt/lfs/run
