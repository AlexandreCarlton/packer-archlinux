#!/bin/sh

# Script used to set up a base environment before provisioning with ansible
# Also configures for vagrant use (which could be done with ansible but we'll see)

set -e # Stop on first error
set -x # Show what we're executing

# Ensure system clock is accurate.
timedatectl set-ntp true

# Force synchronisation of package database (so we can install reflector)
pacman --sync --refresh --refresh

# Generate a list of the fastest mirrors (takes about a minute)
# Pacstrap copies this across into our new installation.
pacman --sync --noconfirm reflector
reflector --protocol https --number 20 --sort rate --save /etc/pacman.d/mirrorlist

/bin/sh ./partition.sh

pacstrap /mnt base base-devel

# Generate an fstab file with labels (not UUIDs)
genfstab -t LABEL /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash < ./chroot.sh

if greq --quiet 'hypervisor' /proc/cpuinfo; then
  arch-chroot /mnt /bin/bash < ./packer.sh
fi

umount -R /mnt
sudo systemctl reboot
