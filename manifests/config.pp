#
# == Class: cobbler::config
#
# Manage cobbler configuration
#
class cobbler::config
(
  $distro_path,
  $manage_dhcp,
  $dhcp_dynamic_range,
  $manage_dns,
  $dns_option,
  $dhcp_option,
  $manage_tftpd,
  $tftpd_option,
  $server_ip,
  $next_server_ip,
  $nameservers,
  $dhcp_interfaces,
  $dhcp_subnets,
  $defaultrootpw,
  $allow_access,
  $default_kickstart,
  $webroot,
  $auth_module,
  $noops,

) inherits cobbler::params {

  # Validate parameters used in this class. Some parameters are validated in the 
  # main class as they are also used there.
  validate_bool($manage_dns)
  validate_bool($manage_tftpd)
  validate_re($dns_option, ['^bind$', '^dnsmasq$'])
  validate_re($tftpd_option, ['^in_tftpd$'])
  validate_string($auth_module)

  if $dhcp_subnets { validate_array($dhcp_subnets) }

  # file defaults
  File {
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    noop   => $noops,
  }

  file { "${::cobbler::params::proxy_config_prefix}/proxy_cobbler.conf":
    content => template('cobbler/proxy_cobbler.conf.erb'),
    notify  => Class['::apache2::service'],
  }

  file { $distro_path :
    ensure => directory,
    mode   => '0755',
  }

  file { "${distro_path}/kickstarts" :
    ensure => directory,
    mode   => '0755',
  }

  # Convert booleans to integers for use in the template
  $manage_dhcp_int = bool2num($manage_dhcp)
  $manage_dns_int = bool2num($manage_dns)
  $manage_tftpd_int = bool2num($manage_tftpd)

  file { '/etc/cobbler/settings':
    content => template('cobbler/settings.erb'),
    require => Class['::cobbler::install'],
    notify  => Class['::cobbler::service'],
  }

  file { '/etc/cobbler/modules.conf':
    content => template('cobbler/modules.conf.erb'),
    require => Class['::cobbler::install'],
    notify  => Class['::cobbler::service'],
  }

  file { "${::cobbler::params::http_config_prefix}/distros.conf":
    content => template('cobbler/distros.conf.erb'),
    notify  => Class['::apache2::service'],
  }

  file { "${::cobbler::params::http_config_prefix}/cobbler.conf":
    content => template('cobbler/cobbler.conf.erb'),
    notify  => Class['::apache2::service'],
  }

  # logrotate script
  file { '/etc/logrotate.d/cobbler':
    source => 'puppet:///modules/cobbler/logrotate',
  }
}
