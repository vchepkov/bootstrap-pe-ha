# apply PE customizations
plan pe_ha::customize {
  run_task('peadm::remove_pe_repos','primary.localdomain')

  run_command('/opt/puppetlabs/bin/puppet infrastructure tune --local --pe_conf', 'primary.localdomain')

  run_task('peadm::puppet_runonce','primary.localdomain')


}
