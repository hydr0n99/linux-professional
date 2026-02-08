#!/usr/bin/bash

set -eu

sudo -i

# Уменьшения тома под /
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE vg_root

mkfs.ext4 /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt

rsync -avxHAX --progress / /mnt/

for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

chroot /mnt/

# grub-install /dev/sda; update-grub - это мне рекомендовала сделать нейронка, когда я сломал загрузчик, выполняя всё по методичке; возможно, я что-то проморгал, конечно, но починил в итоге так, загрузившись с LiveCD
grub-mkconfig -o /boot/grub/grub.cfg
update-initramfs -u

pvcreate /dev/sda2
vgcreate ubuntu-vg /dev/sda2
lvcreate -n ubuntu-lv -L 13G ubuntu-vg

mkfs.ext4 /dev/ubuntu-vg/ubuntu-lv
mount /dev/ubuntu-vg/ubuntu-lv /mnt

rsync -avxHAX --progress / /mnt/

for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

chroot /mnt/

# grub-install /dev/sda; update-grub
grub-mkconfig -o /boot/grub/grub.cfg
update-initramfs -u

# Создание тома под /var в mirror
pvcreate /dev/sdc /dev/sdd
vgcreate vg_var /dev/sdc /dev/sdd
lvcreate -L 3G -m1 -n lv_var vg_var

mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/
umount /mnt
mount /dev/vg_var/lv_var /var

echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab

reboot

lvremove /dev/vg_root/lv_root
vgremove vg_root
pvremove /dev/sdb

# Выделения тома под /home

lvcreate -n LV_Home -L 20G ubuntu-vg
mkfs.ext4 /dev/ubuntu-vg/LV_Home

mount /dev/ubuntu-vg/LV_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/ubuntu-vg/LV_Home /home/

echo "`blkid | grep Home | awk '{print $2}'` /home ext4 defaults 0 0" >> /etc/fstab

# Работа со снапшотами

touch /home/file{1..10}

lvcreate -L 500M -s -n home_snap /dev/ubuntu-vg/LV_Home

rm /home/file{1..5}

umount /home

lvconvert --merge /dev/ubuntu-vg/home_snap

mount /dev/ubuntu-vg/LV_Home /home

