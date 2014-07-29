#
# = Class: cobbler::dhcp
#
# This module manages ISC DHCP for Cobbler
# https://fedorahosted.org/cobbler/
#
class cobbler::dhcp (
  $package         = $::cobbler::params::dhcp_package,
  $version         = $::cobbler::params::dhcp_version,
  $service         = $::cobbler::params::dhcp_service,
  $nameservers     = $::cobbler::params::nameservers,
  $interfaces      = $::cobbler::params::dhcp_interfaces,
  $subnets         = undef,
  $dynamic_range   = $::cobbler::params::dhcp_dynamic_range,
) inherits cobbler::params {
  include ::cobbler

  $dhcp_interfaces    = $interfaces
  $dhcp_subnets       = $subnets
  $dhcp_dynamic_range = $dynamic_range

  package { 'dhcp':
    ensure => present,
    name   => $package,
  }

  service { 'dhcpd':
    ensure  => running,
    name    => $service,
    require => [
      File['/etc/cobbler/dhcp.template'],
      Package['dhcp'],
      Exec['cobblersync'],
    ],
  }

  file { '/etc/cobbler/dhcp.template':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['cobbler'],
    content => template('cobbler/dhcp.template.erb'),
    notify  => Exec['cobblersync'],
  }

}
