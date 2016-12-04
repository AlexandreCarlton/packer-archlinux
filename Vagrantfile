# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'etc'
windows_user = Etc.getlogin
vm_user = windows_user.downcase

Vagrant.configure(2) do |config|

  config.vm.box = "archlinux"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = false
  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.cpus = 2
    vb.memory = 2048
    if Gem.win_platform?
      vb.customize [
        "modifyvm", :id,
         '--audio', 'dsound',
         '--audiocontroller', 'ac97'
      ]
    end
  end

end
