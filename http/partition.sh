#!/bin/sh

# Basic partitioning; tweak later.

DEVICE="${1:-/dev/sda}"
boot_partition="${DEVICE}1"
root_partition="${DEVICE}2"

parted "${DEVICE}" --script mklabel gpt
if [ -d /sys/firmware/efi ]; then
  parted "${DEVICE}" --script --align=optimal mkpart ESP fat32 1MiB 1GiB
else
  parted "${DEVICE}" --script --align=optimal mkpart primary ext2 1MiB 1GiB
fi
parted "${DEVICE}" --script set 1 boot on
parted "${DEVICE}" --script --align=optimal mkpart primary btrfs 1GiB 100%

# Note: We must have:
#  - 'keyboard' and 'encrypt' hooks in mkinitcpio.conf
#  -  cryptdevice=LABEL=root:cryptroot root=/dev/mapper/cryptroot
printf 'password' | cryptsetup luksFormat "${root_partition}"
# cryptroot is the label by which we reference the encrypted partition.
printf 'password' | cryptsetup open "${root_partition}" cryptroot

if [ -d /sys/firmware/efi ]; then
  mkfs.fat -F 32 -n 'boot' "${boot_partition}"
else
  mkfs.ext2 -L 'boot' "${boot_partition}"
fi
mkfs.btrfs -L 'root' /dev/mapper/cryptroot

# TODO: mount -o defaults,noatime,nodev,nosuid,(noexec)
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount "${boot_partition}" /mnt/boot
