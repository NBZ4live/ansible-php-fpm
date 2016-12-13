# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
#      config.vm.box = "ubuntu/trusty64" # Ubuntu 14.04
     config.vm.box = "ubuntu/xenial64" # Ubuntu 16.04
#     config.vm.box = "debian/jessie64" # Debian 8

    config.vm.network "public_network"

    config.vm.provision "ansible" do |ansible|
      ansible.verbose = true
      ansible.playbook = "tests/vagrant.yml"
    end
end
