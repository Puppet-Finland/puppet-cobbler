# == Class: cobbler::install
#
# Install packages required by Cobbler
#
class cobbler::install
(
  $noops,

) inherits cobbler::params
{
  Package {
    ensure => present,
    noop   => $noops,
  }

  package { $::cobbler::params::tftp_package: }
  package { $::cobbler::params::syslinux_package: }
  package { $::cobbler::params::package_name:
    require => [ Package[$::cobbler::params::syslinux_package], Package[$::cobbler::params::tftp_package], Class['cobbler::dependency']],
  }
}
