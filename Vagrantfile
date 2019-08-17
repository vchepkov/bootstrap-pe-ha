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

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box      = "centos/7"
  config.vm.synced_folder ".", "/vagrant"

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

    master.vm.provider "virtualbox" do |vb|
      vb.name   = "primary"
      vb.memory = "4096"
      vb.cpus   = "2"
    end

    master.vm.provision "shell", run: "once", inline: <<-SHELL
      systemctl restart rsyslog
      systemctl mask firewalld
      systemctl stop firewalld
      yum install -y git
      cd /root
      git clone https://github.com/glarizza/pe_curl_requests.git
      DOWNLOAD_VERSION=2017.3.1 pe_curl_requests/installer/download_pe_tarball.sh
      tar xf puppet-enterprise-2017.3.1-el-7-x86_64.tar.gz
      cd puppet-enterprise-2017.3.1-el-7-x86_66
      cat <<-EOF > pe.conf
{
  "console_admin_password": "puppet2017"
  "puppet_enterprise::puppet_master_host": "%{::trusted.certname}"
  "puppet_enterprise::profile::master::code_manager_auto_configure": true
  "puppet_enterprise::profile::master::r10k_remote": "https://github.com/vchepkov/bootstrap-pe-ha.git"
}
EOF
      ./puppet-enterprise-installer -y -c pe.conf
      /opt/puppetlabs/bin/puppet resource host primary.localdomain ip=192.168.50.20
      /opt/puppetlabs/bin/puppet resource host replica.localdomain ip=192.168.50.21
      echo '*' > /etc/puppetlabs/puppet/autosign.conf
      /opt/puppetlabs/bin/puppet agent -t 
    SHELL
  end

  # Replica
  config.vm.define "replica", autostart: false do |node|
    node.vm.hostname = "replica.localdomain"
    node.vm.network "private_network", ip: "192.168.50.21"

    node.vm.provider "virtualbox" do |vb|
      vb.name   = "replica"
      vb.memory = "4096"
      vb.cpus   = "2"
    end

    node.vm.provision "shell", run: "once", inline: <<-SHELL
      systemctl restart rsyslog
      systemctl mask firewalld
      systemctl stop firewalld
      yum -y install http://yum.puppet.com/puppet5/el/7/x86_64/puppet-agent-5.3.1-1.el7.x86_64.rpm
      /opt/puppetlabs/bin/puppet resource host primary.localdomain ip=192.168.50.20
      /opt/puppetlabs/bin/puppet resource host replica.localdomain ip=192.168.50.21
      /opt/puppetlabs/bin/puppet config set server primary.localdomain --section agent
      curl -k https://primary.localdomain:8140/packages/current/install.bash | bash -s -- --puppet-service-ensure stopped
      /opt/puppetlabs/bin/puppet agent -t --waitforcert 60
    SHELL
  end
end
