#
# == Class: cobbler::service
#
# Manage cobbler service
#
class cobbler::service
(
  $distro_path,
  $noops,
)
{
  service { 'cobbler':
    ensure  => running,
    name    => $::cobbler::params::service_name,
    enable  => true,
    require => [ Class['::cobbler::install'], File["${distro_path}/kickstarts"] ],
    noop    => $noops,
  }
}
