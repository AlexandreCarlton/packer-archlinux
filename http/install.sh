#!/bin/sh

# Script used to set up a base environment before provisioning with ansible
# Also configures for vagrant use (which could be done with ansible but we'll see)

# Later this will be broken up into 

set -e # Stop on first error
set -x # Show what we're executing

# Ensure system clock is accurate.
timedatectl set-ntp true

# Generate a list of the fastest mirrors (takes about a minute)
# Pacstrap copies this across into our new installation.
pacman --sync reflector
reflector --protocol https --number 20 --sort rate --save /etc/pacman.d/mirrorlist

/bin/sh ./partition.sh

pacstrap /mnt base base-devel

# Generate an fstab file with UUIDs.
# Consider using labels; everyone seems to love UUIDs but you can't refer to a partition by /dev/disk/by-label/<partition>
genfstab -t UUID /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash < ./chroot.sh
arch-chroot /mnt /bin/bash < ./packer.sh

umount -R /mnt
sudo systemctl reboot