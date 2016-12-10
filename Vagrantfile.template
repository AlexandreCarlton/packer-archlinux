# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = 'archlinux'

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = true

    vb.cpus = 1
    vb.memory = 1024

    vb.customize [
      'modifyvm', :id,
      '--clipboard', 'bidirectional'
    ]

    if Gem.win_platform?
      vb.customize [
        'modifyvm', :id,
         '--audio', 'dsound',
         '--audiocontroller', 'ac97'
      ]
    end
  end

end
