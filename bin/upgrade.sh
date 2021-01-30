#!/bin/sh

bolt module install --no-resolve
bolt plan run peadm::upgrade --params @upgrade.json
