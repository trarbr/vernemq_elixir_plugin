# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.ssh.username = "ubuntu"

  config.vm.provision "shell", path: "provision.sh"
end
