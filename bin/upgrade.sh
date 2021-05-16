#!/bin/sh

bolt module install --no-resolve
bolt plan run peadm::upgrade --params @upgrade.json
bolt command run '/opt/puppetlabs/bin/puppet infrastructure tune --local --pe_conf' -t primary.localdomain
# workaround for bug in remove_old_pe_packages plan
bolt command run '/bin/mkdir -p /opt/puppetlabs/server/data/packages/public /opt/puppetlabs/server/data/staging' -t replica.localdomain
bolt command run '/opt/puppetlabs/bin/puppet infrastructure run remove_old_pe_packages pe_version=current' -t primary.localdomain
