# packer-archlinux

Packer template to deploy and provision my Arch Linux setup.

Downloading an iso sticks it in PACKER_CACHE_DIR, under in common/step_download.go:75
```go
hash := sha1.Sum([]byte(url))
hex.EncodeToString(hash[:])
```
So it seems like it just hashes the url.
(On Linux we should probably set PACKER_CACHE_DIR to ~/.cache/packer)


We've split this up into archlinux-packer.json and ansible-packer.json; this
allows us to test our ansible module more easily without having to configure
Arch Linux again each time.

To ssh in, looks like we need this in the sudoers:
```
Defaults env_keep += "SSH_AUTH_SOCK"
```
stick it in `/etc/sudoers.d/root_ssh_agent`

## Help! I don't have sound!
You'll have to enable it in VirtualBox; I haven't found a way to do this via Vagrant.
