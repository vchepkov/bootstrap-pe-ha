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

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box      = "centos/7"
  config.vm.synced_folder ".", "/vagrant"

  config.vm.provision :hosts do |h|
    h.add_localhost_hostnames = false
    h.add_host '192.168.50.20', ['primary.localdomain', 'primary']
    h.add_host '192.168.50.21', ['replica.localdomain', 'replica']
  end

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

    master.vm.provision "shell", inline: <<-SHELL
      systemctl restart rsyslog
      systemctl mask firewalld
      systemctl stop firewalld
      yum install -y git
      cd /root
      git clone https://github.com/glarizza/pe_curl_requests.git
      DOWNLOAD_VERSION=2018.1.11 pe_curl_requests/installer/download_pe_tarball.sh 2>/dev/null
      tar xf puppet-enterprise-2018.1.11-el-7-x86_64.tar.gz
      cd puppet-enterprise-2018.1.11-el-7-x86_64
      cat <<-EOF > pe.conf
{
  "console_admin_password": "puppet2018"
  "pe_install::disable_mco": false
  "pe_repo::enable_bulk_pluginsync": false
  "puppet_enterprise::send_analytics_data": false
  "puppet_enterprise::ssl_protocols": ["TLSv1.2"]
  "puppet_enterprise::puppet_master_host": "%{::trusted.certname}"
  "puppet_enterprise::profile::master::code_manager_auto_configure": true
  "puppet_enterprise::profile::master::r10k_remote": "https://github.com/vchepkov/bootstrap-pe-ha.git"
  "puppet_enterprise::profile::master::check_for_updates": false
}
EOF
      ./puppet-enterprise-installer -y -c pe.conf
      echo '*' > /etc/puppetlabs/puppet/autosign.conf
      # PE needs two runs to be fully initialized
      /opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-splay --show_diff --verbose
      /opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-splay --show_diff --verbose
      echo puppet2018 | /opt/puppetlabs/bin/puppet-access login --username admin --lifetime 0
      /opt/puppetlabs/bin/puppet-code deploy --all
    SHELL
  end

  # Replica
  config.vm.define "replica", autostart: false do |node|
    node.vm.hostname = "replica.localdomain"
    node.vm.network "private_network", ip: "192.168.50.21"

    node.vm.provider "virtualbox" do |vb|
      vb.name   = "replica"
      vb.memory = "6144"
      vb.cpus   = "2"
    end

    node.vm.provision "shell", inline: <<-SHELL
      systemctl restart rsyslog
      systemctl mask firewalld
      systemctl stop firewalld
      curl -sS -k https://primary.localdomain:8140/packages/current/install.bash | bash -s -- --puppet-service-ensure stopped
      /opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-splay --show_diff --verbose --waitforcert 60
    SHELL
  end
end
