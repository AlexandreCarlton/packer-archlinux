#!/bin/sh
set -e
set -x

ROOT_PARTITION=/dev/sda3

# Add key to automatically unlock the partition by sticking it in rootfs
# This is so that packer can complete a build and still have encryption ready.
# It is the default key for crypt and so does not need to be specified in syslinux.cfg.
# We'll have to remove this later.
if grep --quiet 'hypervisor' /proc/cpuinfo; then
  printf 'password' > /crypto_keyfile.bin
  printf 'password' | cryptsetup luksAddKey "${ROOT_PARTITION}" /crypto_keyfile.bin
  sed --in-place '/FILES=.*/a FILES+=" /crypto_keyfile.bin"' /etc/mkinitcpio.conf
fi

# Insert encrypt hook, and place keyboard hook before this (so that we can type the password)
# We don't need keymap because we're not using a foreign keyboard layout.
# This will be replaced by Ansible's mkinitcpio.conf
sed --in-place 's/block filesystems keyboard/keyboard block encrypt filesystems/' /etc/mkinitcpio.conf
# mkinitcpio complains that fsck.btrfs without this.
pacman --sync --noconfirm btrfs-progs
mkinitcpio -p linux

if [ -d /sys/firmware/efi ]; then
  # We've booted with UEFI
  bootctl --path=/boot install

  echo 'default arch' > /boot/loader/loader.conf
  echo 'timeout 3' >> /boot/loader/loader.conf

  echo 'title Arch Linux' > /boot/loader/entries/arch.conf
  echo 'linux /vmlinuz-linux' >> /boot/loader/entries/arch.conf
  echo 'initrd /initramfs-linux.img' >> /boot/loader/entries/arch.conf
  echo "options cryptdevice=${ROOT_PARTITION}:cryptroot root=/dev/mapper/cryptroot" >> /boot/loader/entries/arch.conf
else
  # We've booted with BIOS
  pacman --sync --noconfirm syslinux gptfdisk
  syslinux-install_update -i -a -m
  # TODO: Use UUID; labels aren't accessible if they're in an encrypted partition
  sed --in-place "s|root=/dev/sda3|cryptdevice=${ROOT_PARTITION}:cryptroot root=/dev/mapper/cryptroot|" /boot/syslinux/syslinux.cfg
  pacman --remove --cascade --recursive --nosave --noconfirm gptfdisk
fi
