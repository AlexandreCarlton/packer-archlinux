
VAGRANT_BOX_NAME := archlinux-alexandre

all: build/archlinux.box

build/archlinux.box:
	packer build archlinux.json

vagrant-add: build/archlinux.box
	vagrant box add --name $(VAGRANT_BOX_NAME) build/archlinux.box

vagrant-rm:
	vagrant box remove $(VAGRANT_BOX_NAME)
