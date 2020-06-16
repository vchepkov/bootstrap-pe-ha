#!/bin/sh

bolt puppetfile install
bolt plan run peadm::provision --params @provision.json
