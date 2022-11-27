#!/bin/sh
set -e
set -x

# TODO: This should take in the root partition instead of just the device
DEVICE="$1"

if printf '%s' "${DEVICE}" | grep --quiet '[0-9]$'; then
  # Devices with trailing digits tend to have 'p<i>' as the partition suffix to avoid confusion.
  root_partition="${DEVICE}p3"
else
  root_partition="${DEVICE}3"
fi

# Ensure configuration file /etc/mkinitcpio.conf is present.
pacman --sync --noconfirm mkinitcpio

# Add key to automatically unlock the partition by sticking it in rootfs
# This is so that packer can complete a build and still have encryption ready.
# It is the default key for crypt and so does not need to be specified in syslinux.cfg.
# We'll have to remove this later.
if grep --quiet 'hypervisor' /proc/cpuinfo; then
  printf 'password' > /crypto_keyfile.bin
  printf 'password' | cryptsetup luksAddKey "${root_partition}" /crypto_keyfile.bin
  # FILES+=('foo') doesn't seem to work beyond the first invocation :/
  sed --in-place '/FILES=.*/a FILES="/crypto_keyfile.bin"' /etc/mkinitcpio.conf
fi

# Insert encrypt hook, and place keyboard hook before this (so that we can type the password)
# We don't need keymap because we're not using a foreign keyboard layout.
# This will be replaced by Ansible's mkinitcpio.conf
# TODO: Make this less fragile; if this doesn't succeed then we can't unlock the filesystem.
sed --in-place 's/block filesystems/block encrypt filesystems/' /etc/mkinitcpio.conf
# mkinitcpio complains that fsck.btrfs without this.
pacman --sync --noconfirm btrfs-progs
# we need the linux preset
pacman --sync --noconfirm linux
mkinitcpio -p linux

if [ -d /sys/firmware/efi ]; then
  # We've booted with UEFI
  bootctl --path=/boot install

  {
    echo 'default arch'
    echo 'timeout 3'
  } > /boot/loader/loader.conf

  {
    echo 'title Arch Linux'
    echo 'linux /vmlinuz-linux'
    echo 'initrd /initramfs-linux.img'
    echo "options cryptdevice=${root_partition}:cryptroot root=/dev/mapper/cryptroot"
  } > /boot/loader/entries/arch.conf
else
  # We've booted with BIOS
  pacman --sync --noconfirm syslinux gptfdisk
  syslinux-install_update -i -a -m
  # TODO: Use UUID; labels aren't accessible if they're in an encrypted partition
  sed --in-place "s|root=/dev/sda3|cryptdevice=${root_partition}:cryptroot root=/dev/mapper/cryptroot|" /boot/syslinux/syslinux.cfg
  pacman --remove --cascade --recursive --nosave --noconfirm gptfdisk
fi

# Ensure we can hit the internet post-boot.
pacman --sync --noconfirm iwd

# Arch doesn't allow password-less root by default; so we change this so we can log in later.
echo 'root:password' | chpasswd
