#!/bin/sh

# Script used to set up a base environment before provisioning with ansible
# Also configures for vagrant use (which could be done with ansible but we'll see)

set -e
set -x

DEVICE="${1:?Provide a device name (e.g. /dev/sda or /dev/nvme0n1)}"

# Ensure system clock is accurate.
timedatectl set-ntp true

# Force synchronisation of package database (so we can install things later, if necessary).
pacman --sync --refresh --refresh

./partition.sh "${DEVICE}"

pacstrap /mnt base base-devel

# Generate an fstab file with UUID (this can be accessed via encryption).
genfstab -t UUID /mnt >> /mnt/etc/fstab

cp chroot.sh /mnt/
arch-chroot /mnt /chroot.sh "${DEVICE}"
rm /mnt/chroot.sh

if grep --quiet 'hypervisor' /proc/cpuinfo; then
  cp packer.sh /mnt/
  arch-chroot /mnt /packer.sh
  rm /mnt/packer.sh
fi

umount -R /mnt
sudo systemctl reboot
