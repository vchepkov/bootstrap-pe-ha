#!/bin/sh -e

bolt module install --force
bolt plan run peadm::install --params @install.json
bolt task run service name=puppet action=stop --no-verbose -t primary.localdomain,replica.localdomain
bolt command run '/opt/puppetlabs/bin/puppet infrastructure tune --local --pe_conf' -t primary.localdomain
bolt task run peadm::puppet_runonce --no-verbose -t primary.localdomain
bolt task run service name=puppet action=start --no-verbose -t primary.localdomain,replica.localdomain
