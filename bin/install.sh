#!/bin/sh -e

bolt module install --force
bolt plan run peadm::install --params @install.json
bolt plan run pe_ha::customize
