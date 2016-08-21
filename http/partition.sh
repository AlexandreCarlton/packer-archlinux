#!/bin/sh

# Basic partitioning; tweak later.

# Can get name from lsblk --nodeps --noheadings --output NAME
DEVICE='/dev/sda'
boot_partition="${DEVICE}1"
swap_partition="${DEVICE}2"
root_partition="${DEVICE}3"

# Note we are doing this for a BIOS system; for UEFI we'd have mkpart ESP fat32
parted "${DEVICE}" --script mklabel gpt
parted "${DEVICE}" --script --align=optimal mkpart primary ext2 1MiB 257MiB
parted "${DEVICE}" --script set 1 boot on
parted "${DEVICE}" --script --align=optimal mkpart primary linux-swap 257MiB 4GiB
parted "${DEVICE}" --script --align=optimal mkpart primary ext4 4GiB 100%

mkfs.ext2 -L 'boot' "${boot_partition}"
mkfs.ext4 -L 'root' "${root_partition}"

mkswap "${swap_partition}"
swapon "${swap_partition}"

# TODO: mount -o defaults,noatime,nodev,nosuid,(noexec)
mount "${root_partition}" /mnt
mkdir /mnt/boot
mount "${boot_partition}" /mnt/boot