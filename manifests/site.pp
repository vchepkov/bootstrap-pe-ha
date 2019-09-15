# Workaround for bug PE-27066
# Master's catalog can't be compiled by replica
if $trusted['certname'] == 'primary.localdomain' {
  node_group { 'PE Primary Master Agent':
    ensure  => 'present',
    classes => {
      'puppet_enterprise::profile::agent' => {
        'server_list' => ['primary.localdomain:8140']
      }
    },
    parent  => 'PE Infrastructure Agent',
    rule    => ['or', ['=', 'name', 'primary.localdomain']],
  }
}
