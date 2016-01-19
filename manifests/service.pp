#
# == Class: cobbler::service
#
# Manage cobbler service
#
class cobbler::service
(
  $distro_path,
  $noops,

) inherits cobbler::params
{
  service { 'cobbler':
    ensure  => running,
    name    => $::cobbler::params::service_name,
    enable  => true,
    require => [ Class['::cobbler::install'], File["${distro_path}/kickstarts"] ],
    notify  => Exec['cobblersync'],
    noop    => $noops,
  }

  # cobbler sync has to be done after the service has been restarted 
  exec { 'cobblersync':
    command     => '/usr/bin/cobbler sync',
    refreshonly => true,
  }
}
