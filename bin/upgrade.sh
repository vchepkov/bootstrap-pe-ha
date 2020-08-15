#!/bin/sh

bolt puppetfile install
bolt plan run peadm::upgrade --params @upgrade.json
