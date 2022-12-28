#!/bin/sh -e

bolt module install --force
bolt plan run peadm::upgrade --params @upgrade.json
bolt plan run pe_ha::customize clean_old_packages=true
