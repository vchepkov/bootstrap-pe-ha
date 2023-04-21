#!/bin/sh -e

bolt module install --force
bolt plan run peadm::upgrade --params @upgrade.json
bolt plan run pe_ha::customize
bolt command run '/opt/puppetlabs/bin/puppet infrastructure run remove_old_pe_packages' -t primary.localdomain
