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

Install a basic archlinux set up:

```bash
$ systemctl restart dhcpcd # ethernet
$ wifi-menu # wi-fi
$ pacman -Syy
$ pacman -S git
$ git clone --recursive https://github.com/AlexandreCarlton/packer-archlinux.git
$ cd packer-archlinux/http
$ ./install.sh /dev/sda
```

This will reboot the system.
Pull down the `ansible-archlinux` repository and run the playbook you desire:

```bash
$ git clone --recursive https://github.com/AlexandreCarlton/ansible-archlinux.git
$ cd ansible-archlinux
$ ansible-playbook --connection=local <machine>.yml
```

Now that your system is set up, remember to change your passwords:
```bash
$ sudo cryptsetup --verify-passphrase --key-slot=0 luksChangeKey /dev/sda3
$ passwd
```

(Thought: what if we just enabled `sshd`, and provisioned remotely?)

### Issues
I've had a few issues here and there, so I figured I would record some of them
here and the workarounds used to circumvent them.

### Radeon
On boot, I kept getting an error message similar to:

```
[    1.000000] [drm:.r600_ring_test [radeon]] *ERROR* radon: ring 0 test failed (scratch(0x8504)=0xCAFEDEAD)
[    1.000000] radeon 000:10:00.0: disabling GPU acceleration
```

Hopping into the bios and turning off switchable graphics detection and using
integrated graphics appeared to solve this.

### Helpful links

 - [Rfkill issues on Lenovo T420 whilst running connman and wpa_supplicant](https://ianweatherhogg.com/tech/2015-08-05-rfkill-connman-enable-wifi.html)

## Upgrading
To use newer ISO files, you'll have to edit:

 - `iso_url`, pointing to a new url
 - `iso_checksum`, found on the [Downloads](https://www.archlinux.org/download/) page, under "Checksum"

## Rolling back
If you've borked your system for whatever reason, simply find the snapshot you
wanted to revert to and in your bootflags go:

    rootflags=subvol=@/.snapshots/<number>/snapshot

And you'll boot into that snapshot.
This can be made into a new, default snapshot with `snapper rollback`.

## Testing in CI
Both Travis CI and AppVeyor do not run virtual machine workers with VT-X
enabled.
This prevents the launching of 64-bit virtual machines inside the workers, so
we are unable to test an actual build to see if it works; at best, we can
validate the `archlinux.json` file.

## Development
Building the entire box from scratch takes a long time, especially if you want
to test a small role. For this reason, you can build a minimal ArchLinux box
with:

```
packer build archlinux-base.json
```

You can then build a new box based on this with:
```
packer build -on-error=ask archlinux-development.json
```
If a step fails, the VM will remain present so that it can be debugged.
