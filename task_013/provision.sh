#!/bin/bash

set -eu

arr=("sdb" "sdc" "sdd")

for ((i=0; i<${#arr[@]}; i++)); do
    mkfs.ext4 "/dev/${arr[$i]}"
    mkdir -p "/mnt/disk$i"
    mount "/dev/${arr[$i]}" "/mnt/disk$i"
    uuid=$(blkid -s UUID -o value "/dev/${arr[$i]}")
    echo "UUID=${uuid} /mnt/disk$i ext4 defaults,nofail 0 2" >> /etc/fstab
done
