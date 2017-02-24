#!/bin/sh

# Set-up instructions specifically so that the built box can be provisioned by packer.
# We create settings that also apply to vagrant so we don't create two different users
# that do the same thing.

# Set root password as vagrant - necesary for vagrant, probs not packer.
passwd <<PASSWD
vagrant
vagrant
PASSWD

# Add vagrant user - necessary for packer.
# UNLESS - we just ssh as root with password root, Or make a 'packer' user.
# So we could decouple vagrant from here completely!
useradd vagrant --user-group --create-home
passwd vagrant <<PASSWD
vagrant
vagrant
PASSWD

# Give relevant permissions - necessary for vagrant (hopefully - then we can stick it in an ansible role)
# Defaults env_keep += "SSH_AUTH_SOCK" is necessary for provisioning; probably only need this.
cat <<SUDOERS > /etc/sudoers.d/vagrant
Defaults:vagrant !requiretty
Defaults env_keep += "SSH_AUTH_SOCK"
vagrant ALL=(ALL) NOPASSWD: ALL
SUDOERS
chmod 0440 /etc/sudoers.d/vagrant

# Have to enable these services so we can ssh in and execute vagrant operations.
pacman --sync --needed --noconfirm openssh
systemctl daemon-reload
systemctl enable sshd
systemctl enable dhcpcd
