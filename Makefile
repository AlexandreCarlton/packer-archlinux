
VAGRANT_BOX_NAME := archlinux-alexandre

all: build

build: build/archlinux.box
.PHONY: build

build/archlinux.box:
	packer build archlinux.json

# If something goes wrong, the VM isn't automatically cleaned up.
debug-build:
	packer build -on-error=abort archlinux.json

vagrant-add: build/archlinux.box
	vagrant box add --name $(VAGRANT_BOX_NAME) build/archlinux.box
.PHONY: vagrant-add

vagrant-rm:
	vagrant box remove $(VAGRANT_BOX_NAME)
.PHONY: vagrant-rm

clean:
	rm -rf build
	rm -rf output-virtualbox-iso
.PHONY: clean
