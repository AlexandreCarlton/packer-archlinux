#!/bin/sh
set -e 
set -x

mkinitcpio -p linux

# Syslinux (since we're using BIOS)
# We deploy our own config via Ansible... we'd need to know the root uid, though - /dev/disk/by-label?
pacman --sync --noconfirm syslinux gptfdisk
syslinux-install_update -i -a -m
pacman --remove --cascade --recursive --nosave --noconfirm gptfdisk
