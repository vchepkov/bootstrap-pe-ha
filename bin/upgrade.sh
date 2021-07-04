#!/bin/sh

bolt module install --no-resolve
bolt plan run peadm::upgrade --params @upgrade.json
bolt command run '/opt/puppetlabs/bin/puppet infrastructure tune --local --pe_conf' -t primary.localdomain
bolt command run '/opt/puppetlabs/bin/puppet infrastructure run remove_old_pe_packages' -t primary.localdomain
