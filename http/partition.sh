#!/bin/sh

# A partitioning set up for:
# - boot
# - swap
# - root (a btrfs subvolume)
#   - @ (/)
#   - @home (/home)
#   - @var (/var)
#   - @snapshots (/.snapshots)

DEVICE="${1:-/dev/sda}"
boot_partition="${DEVICE}1"
swap_partition="${DEVICE}2"
root_partition="${DEVICE}3"

parted "${DEVICE}" --script mklabel gpt
if [ -d /sys/firmware/efi ]; then
  parted "${DEVICE}" --script --align=optimal mkpart ESP fat32 1MiB 1GiB
else
  parted "${DEVICE}" --script --align=optimal mkpart primary ext2 1MiB 1GiB
fi
parted "${DEVICE}" --script set 1 boot on
parted "${DEVICE}" --script --align=optimal mkpart primary linux-swap 1GiB 5GiB
parted "${DEVICE}" --script --align=optimal mkpart primary btrfs 5GiB 100%

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

mkswap "${swap_partition}"
swapon "${swap_partition}"
mkfs.btrfs -L 'root' /dev/mapper/cryptroot

# Create top level subvolumes
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home

# Set @ to be the default subvolume for root.
# Snapper (if used) will later manage the default subvolume for us.
btrfs subvolume set-default /mnt/@

umount /mnt

# Mount the subvolumes
# TODO: /sys/block/sda/queue/rotational = 1 if using HDD, 0 if SSD.

# Note that when we call genfstab, subvol will be set (and will later be undone by ansible).
# Regardless, it is worth emphasising that we do not explicitly mount @ to /.
                         mount -o compress=lzo,noatime                   /dev/mapper/cryptroot /mnt
mkdir /mnt/home       && mount -o compress=lzo,noatime,subvol=@home      /dev/mapper/cryptroot /mnt/home
# Mount /boot (non-btrfs)
mkdir /mnt/boot       && mount                                           "${boot_partition}"   /mnt/boot
