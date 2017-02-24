#!/bin/sh
set -e
set -x

# Add key to automatically unlock the partition by sticking it in rootfs
# This is so that packer can complete a build and still have encryption ready.
# It is the default key for crypt and so does not need to be specified in syslinux.cfg.
# We'll have to remove this later.
printf 'password' > /crypto_keyfile.bin
printf 'password' | cryptsetup luksAddKey /dev/sda2 /crypto_keyfile.bin
# Insert encrypt hook, and place keyboard hook before this (so that we can type the password)
# We don't need keymap because we're not using a foreign keyboard layout.
# This will be replaced by Ansible's mkinitcpio.conf
sed --in-place 's|FILES=""|FILES="/crypto_keyfile.bin"|' /etc/mkinitcpio.conf
sed --in-place 's/block filesystems keyboard/keyboard block encrypt filesystems/' /etc/mkinitcpio.conf
# mkinitcpio complains that fsck.btrfs without this.
pacman --sync --noconfirm btrfs-progs
mkinitcpio -p linux

# Syslinux (since we're using BIOS)
# We deploy our own config via Ansible... we'd need to know the root uid, though - /dev/disk/by-label?
pacman --sync --noconfirm syslinux gptfdisk
syslinux-install_update -i -a -m
sed --in-place 's|root=/dev/sda3|cryptdevice=/dev/sda2:cryptroot root=/dev/mapper/cryptroot|' /boot/syslinux/syslinux.cfg

pacman --remove --cascade --recursive --nosave --noconfirm gptfdisk
