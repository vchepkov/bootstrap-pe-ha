#!/bin/sh -e

bolt module install --force
bolt plan run peadm::install --params @install.json
bolt command run '/opt/puppetlabs/bin/puppet infrastructure tune --local --pe_conf' -t primary.localdomain
