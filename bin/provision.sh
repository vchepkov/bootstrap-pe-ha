#!/bin/sh

bolt module install --no-resolve
bolt plan run peadm::provision --params @provision.json
bolt task run puppet_conf --targets primary.localdomain,replica.localdomain action=set section=agent setting=splay value=true
bolt command run '/opt/puppetlabs/bin/puppet infrastructure tune --local --pe_conf' -t primary.localdomain
