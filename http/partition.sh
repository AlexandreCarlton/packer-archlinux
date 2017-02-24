#!/bin/sh

# Basic partitioning; tweak later.

# Can get name from lsblk --nodeps --noheadings --output NAME
# Should probably export these in install.sh
DEVICE='/dev/sda'
boot_partition="${DEVICE}1"
root_partition="${DEVICE}2"

# Note we are doing this for a BIOS system; for UEFI we'd have mkpart ESP fat32
parted "${DEVICE}" --script mklabel gpt
parted "${DEVICE}" --script --align=optimal mkpart primary ext2 1MiB 257MiB
parted "${DEVICE}" --script set 1 boot on
parted "${DEVICE}" --script --align=optimal mkpart primary btrfs 257MiB 100%

# Note: We must have:
#  - 'keyboard' and 'encrypt' hooks in mkinitcpio.conf
#  -  cryptdevice=LABEL=root:cryptroot root=/dev/mapper/cryptroot
printf 'password' | cryptsetup luksFormat "${root_partition}"
# cryptroot is the label by which we reference the encrypted partition.
printf 'password' | cryptsetup open "${root_partition}" cryptroot

mkfs.ext2 -L 'boot' "${boot_partition}"
mkfs.ext4 -L 'root' /dev/mapper/cryptroot

# TODO: mount -o defaults,noatime,nodev,nosuid,(noexec)
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount "${boot_partition}" /mnt/boot
