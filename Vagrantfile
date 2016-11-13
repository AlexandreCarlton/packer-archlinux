# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'etc'
windows_user = Etc.getlogin
vm_user = windows_user.downcase

Vagrant.configure(2) do |config|

  config.vm.box = "archlinux"

  # config.vm.synced_folder ".", "/vagrant", type: "nfs"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = false
  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.cpus = 2
    vb.memory = 2048
  end

end
