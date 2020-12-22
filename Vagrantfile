# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.0.0"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vagrant.plugins = "vagrant-hosts"

  config.vm.box = "centos/8"

  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provision :hosts do |h|
    h.add_localhost_hostnames = false
    h.add_host '192.168.50.20', ['primary.localdomain', 'primary']
    h.add_host '192.168.50.21', ['replica.localdomain', 'replica']
  end

  # Facter is trying to connect to AWS metadata
  config.vm.provision :shell, inline: "/sbin/ip route add unreachable 169.254.0.0/16", run: 'always'

  config.vm.provision :shell, inline: <<-SHELL
      systemctl restart rsyslog
      systemctl mask firewalld
      systemctl stop firewalld
  SHELL

  config.vm.provider :virtualbox do |vb|
    vb.auto_nat_dns_proxy = false
    vb.default_nic_type = "virtio"
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
  end

  # Master
  config.vm.define "primary", primary: true do |master|
    master.vm.hostname = "primary.localdomain"
    master.vm.network "private_network", ip: "192.168.50.20"
    master.vm.network "forwarded_port", guest: 443, host: 8443

    master.vm.provider "virtualbox" do |vb|
      vb.name   = "primary"
      vb.memory = "6144"
      vb.cpus   = "2"
    end
  end

  # Replica
  config.vm.define "replica" do |node|
    node.vm.hostname = "replica.localdomain"
    node.vm.network "private_network", ip: "192.168.50.21"
    node.vm.network "forwarded_port", guest: 443, host: 4443

    node.vm.provider "virtualbox" do |vb|
      vb.name   = "replica"
      vb.memory = "6144"
      vb.cpus   = "2"
    end
  end
end
