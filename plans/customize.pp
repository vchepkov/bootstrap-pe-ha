# apply PE customizations
plan pe_ha::customize (
  Boolean $clean_old_packages = false,
) {
  run_task('service', ['primary.localdomain','replica.localdomain'],
    name   => 'puppet',
    action => 'stop'
  )

  run_command('/opt/puppetlabs/bin/puppet infrastructure tune --local --pe_conf', 'primary.localdomain')

  run_task('peadm::puppet_runonce','primary.localdomain')

  run_task('service', ['primary.localdomain','replica.localdomain'],
    name   => 'puppet',
    action => 'start'
  )

  if $clean_old_packages {
    run_command('/opt/puppetlabs/bin/puppet infrastructure run remove_old_pe_packages', 'primary.localdomain')
  }
}
