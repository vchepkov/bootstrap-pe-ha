#!/bin/sh

bolt module install --no-resolve
bolt plan run peadm::provision --params @provision.json
