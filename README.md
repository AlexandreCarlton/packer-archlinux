# packer-archlinux

Packer template to deploy and provision my Arch Linux setup.

The resulting machine has two partitions:

 - A small boot partition
 - An encrypted root partition

This will set both the root and user passwords to 'vagrant', and the encryption password to 'password'.

## Upgrading
To use newer ISO files, you'll have to edit:

 - `iso_url`, pointing to a new url
 - `iso_checksum`, found on the [Downloads](https://www.archlinux.org/download/) page, under "Checksum"

## Why are your builds failing in CI?

Both Travis CI and AppVeyor do not run virtual machine workers with VT-X enabled.
This prevents the launching of 64-bit virtual machines inside the workers, so these builds will inevitably fail.