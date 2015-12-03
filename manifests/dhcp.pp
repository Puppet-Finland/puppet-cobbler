#
# = Class: cobbler::dhcp
#
# This module manages ISC DHCP for Cobbler
# https://fedorahosted.org/cobbler/
#
class cobbler::dhcp
(
  $nameservers,
  $interfaces,
  $subnets,
  $dynamic_range,
  $netmask

) inherits cobbler::params {

  $dhcp_interfaces    = $interfaces
  $dhcp_subnets       = $subnets
  $dhcp_dynamic_range = $dynamic_range

  package { 'dhcp':
    ensure => present,
    name   => $::cobbler::params::dhcp_package,
  }

  service { 'dhcpd':
    ensure  => running,
    name    => $::cobbler::params::dhcp_service,
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
    require => Class['::cobbler::install'],
    content => template('cobbler/dhcp.template.erb'),
    notify  => Exec['cobblersync'],
  }
}
