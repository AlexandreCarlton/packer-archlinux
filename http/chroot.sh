#!/bin/sh
set -e 
set -x
# Bare minimum to get Arch up and running.
# Anything that can be done in ansible should be omitted here.
# This includes any configuration that differs to what is done here.

# Locale handled by Ansible.
sed --in-place "s/#\(en_US.UTF-8 UTF-8\)/\1/" /etc/locale.gen
systemd-firstboot --locale='en_US.UTF-8'
export LANG='en_US.UTF-8'
locale-gen


# Set timezone
systemd-firstboot --timezone='Australia/Sydney'

# Hostname handled by Ansible
systemd-firstboot --hostname='flygon'

# Mkinitcpio
# We can get a template/file to copy across.
mkinitcpio -p linux


# Vagrant configuration - I feel like this could be done in an ansible role {{{

# Set root password as vagrant - necesary for vagrant, probs not packer.
passwd <<PASSWD
vagrant
vagrant
PASSWD

# Add vagrant user - necessary for packer.
# UNLESS - we just ssh as root with password root.
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

# Get ssh keypair - necessary for vagrant.
# -m 0700
# mkdir -p /home/vagrant/.ssh
# chmod 0700 /home/vagrant/.ssh
# curl --location https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub \
#     --output /home/vagrant/.ssh/authorized_keys
# chmod 0600 /home/vagrant/.ssh/authorized_keys
# chown -R vagrant /home/vagrant/.ssh

# Enable ssh daemon
# TODO: If we get ansible up, create a template.

# sed -i -e 's/\#Pub/Pub/g' /etc/ssh/sshd_config
# sed -i -e's/^#UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
# sed -i -e's/^#GSSAPIAuthentication.*/GSSAPIAuthentication no/' /etc/ssh/sshd_config
# sed -i -e's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
# sed -i -e's/^#AuthorizedKeysFile.*\.ssh\/authorized_keys/AuthorizedKeysFile \.ssh\/authorized_keys/' /etc/ssh/sshd_config

# Have to enable these services so we can ssh in and vagrant.
pacman --sync --needed --noconfirm openssh
systemctl daemon-reload
systemctl enable sshd
systemctl enable dhcpcd

# Virtualbox - can be done in Ansible{{{
# pacman --sync --noconfirm virtualbox-guest-modules-arch virtualbox-guest-utils 
# cat <<VBOX > /etc/modules-load.d/virtualbox.conf 
# vboxguest
# vboxsf
# vboxvideo
# VBOX
# systemctl enable vboxservice
# }}}


# Syslinux (since we're using BIOS)
# We deploy our own config via Ansible... we'd need to know the root uid, though - /dev/disk/by-label?
pacman --sync --noconfirm syslinux gptfdisk
syslinux-install_update -i -a -m
pacman --remove --cascade --recursive --nosave --noconfirm gptfdisk
