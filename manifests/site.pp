# Workaround for bug ENTERPRISE-1284
# Master's catalog shouldn't be compiled by replica before PE2019
if $trusted['certname'] == 'primary.localdomain' and versioncmp($facts['pe_server_version'], '2019') < 0 {
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
