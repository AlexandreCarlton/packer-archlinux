# packer-archlinux

Packer template to deploy and provision my Arch Linux setup.

Downloading an iso sticks it in PACKER_CACHE_DIR, under in common/step_download.go:75
```go
hash := sha1.Sum([]byte(url))
hex.EncodeToString(hash[:])
```
So it seems like it just hashes the url.
(On Linux we should probably set PACKER_CACHE_DIR to ~/.cache/packer)

To ssh in, looks like we need this in the sudoers:
```
Defaults env_keep += "SSH_AUTH_SOCK"
```
stick it in `/etc/sudoers.d/root_ssh_agent`

## Upgrading
To use newer ISO files, you'll have to edit:

 - `iso_url`, pointing to a new url
 - `iso_checksum`, found on the [Downloads](https://www.archlinux.org/download/) page, under "Checksum"

## Help! I don't have sound!
You'll have to enable it in VirtualBox; I haven't found a way to do this via Vagrant.
