#!/bin/sh

# Script used to set up a base environment before provisioning with ansible
# Also configures for vagrant use (which could be done with ansible but we'll see)

set -e
set -x

DEVICE="${1:-/dev/sda}"

# Ensure system clock is accurate.
timedatectl set-ntp true

# Force synchronisation of package database (so we can install reflector)
pacman --sync --refresh --refresh

# We set this instead of reflector if we're just making a test build (to save on bandwidth).
# echo 'Server = http://ftp.iinet.net.au/pub/archlinux/$repo/os/$arch' >  /etc/pacman.d/mirrorlist
# echo 'Server = http://ftp.iinet.net.au/pub/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
# echo 'Server = http://ftp.iinet.net.au/pub/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

# Generate a list of the fastest mirrors (takes about a minute)
# Pacstrap copies this across into our new installation.
pacman --sync --noconfirm reflector
reflector --protocol https --number 20 --sort rate --save /etc/pacman.d/mirrorlist

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
