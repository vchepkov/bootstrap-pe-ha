#!/bin/sh
# Provision replica

PATH=$PATH:/opt/puppetlabs/bin

puppet task run service name=puppet action=stop -n primary.localdomain,replica.localdomain
puppet infrastructure provision replica replica.localdomain
puppet infrastructure status --host replica.localdomain
puppet infrastructure enable replica replica.localdomain --topology mono --yes
puppet infrastructure status
puppet task run service name=puppet action=start -n primary.localdomain,replica.localdomain
