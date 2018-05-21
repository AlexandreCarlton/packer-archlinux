# packer-archlinux

[![Build Status](https://travis-ci.org/AlexandreCarlton/packer-archlinux.svg?branch=master)](https://travis-ci.org/AlexandreCarlton/packer-archlinux)
[![Build status](https://ci.appveyor.com/api/projects/status/s7tcpanctduykfpn?svg=true)](https://ci.appveyor.com/project/AlexandreCarlton/packer-archlinux)

Packer template to deploy and provision my Arch Linux setup.

The resulting machine has two partitions:

 - A small boot partition
 - A swap partition
 - An encrypted root partition

This will set both the root and user passwords to 'vagrant', and the encryption password to 'password'.

## Installing on a real machine
You can use this project to install Arch on a physical computer too. After jumping into the virtual console:

 - Connect to the internet (`systemctl restart dhcpcd` on ethernet, or `wifi-menu` for wireless).
 - Install git (which will require a `pacman -Syy` to update the database).
 - Clone this repo recursively.
 - Change into `http`.
 - Run `install.sh`, providing the device you want to provision if it isn't the default (`/dev/sda`).
 - After the system has rebooted, change into `ansible` and run the relevant playbook with `ansible-playbook -i inventory <machine>.yml`.

### Issues
I've had a few issues here and there, so I figured I would record some of them
here and the workarounds used to circumvent them.

### Radeon
On boot, I kept getting an error message:

```
[drm:.r600_ring_test [radeon]] *ERROR* radon: ring 0 test failed (scratch(0x8504)=0xCAFEDEAD)
radeon 000:10:00.0: disabling GPU acceleration
```

Hopping into the bios and turning off switchable graphics detection and using
integrated graphics appeared to solve this.

### Helpful links

 - [Rfkill issues on Lenovo T420 whilst running connman and wpa_supplicant](https://ianweatherhogg.com/tech/2015-08-05-rfkill-connman-enable-wifi.html)

## Upgrading
To use newer ISO files, you'll have to edit:

 - `iso_url`, pointing to a new url
 - `iso_checksum`, found on the [Downloads](https://www.archlinux.org/download/) page, under "Checksum"

## Why are your builds failing in CI?

Both Travis CI and AppVeyor do not run virtual machine workers with VT-X enabled.
This prevents the launching of 64-bit virtual machines inside the workers, so these builds will inevitably fail.
