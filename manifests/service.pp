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

  # It seems that cobblerd takes a while to become responsive, so we need to 
  # wait a bit before trying to run "cobbler sync". On the test node 10 seconds 
  # seemed to be enough, whereas 5 seconds was not.
  exec { 'cobblersync':
    command     => 'sleep 10; cobbler sync',
    path        => ['/bin', '/usr/bin' ],
    refreshonly => true,
  }

  if str2bool($::has_systemd) {
    # Ensure that "cobbler sync" gets run at boot. Without this dhcpd et al
    # will not get started.
    systemd::service_override { 'cobbler-cobblersync':
      ensure        => 'present',
      service_name  => 'cobblersync',
      template_path => 'cobbler/cobblersync.service.erb',
    }
  }
}
