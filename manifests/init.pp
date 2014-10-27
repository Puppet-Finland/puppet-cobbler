#
# == Class: cobbler
#
# This class manages Cobbler ( http://www.cobblerd.org/ )
#

# === Parameters
#
# [*service_name*]
#   Type: string, default: $::osfamily based
#   Name of the cobbler service
#
# [*package_name*]
#   Type: string, default: $::osfamily based
#   Name of the cobbler package
#
# [*package_ensure*]
#   Type: string, default: 'present'
#   Can be used to set package version
#
# [*distro_path*]
#   Type: string, default: $::osfamily based
#   Defines the location on disk where distro files will be
#   stored. Contents of the ISO images will be copied over
#   in these directories, and also kickstart files will be
#   stored.
#
# [*manage_dhcp*]
#   Type: bool, default: false
#   Wether or not to manage ISC DHCP.
#
# [*dhcp_dynamic_range*]
#   Type: string, default: '0'
#   Range for DHCP server
#
# [*manage_dns*]
#   Type: string, default: false
#   Wether or not to manage DNS
#
# [*dns_option*]
#   Type: string, default: 'dnsmasq'
#   Which DNS deamon to manage - Bind or dnsmasq. If dnsmasq,
#   then dnsmasq has to be used for DHCP too.
#
# [*manage_tftpd*]
#   Type: bool, default: true
#   Wether or not to manage TFTP daemon.
#
# [*tftpd_option*]
#   Type: string, default: 'in_tftpd'
#   Which TFTP daemon to use.
#
# [*server_ip*]
#   Type: string, default: $::ipaddress
#   IP address of a Cobbler server.
#
# [*next_server_ip*]
#   Type: string, default: $::ipaddress
#   Next server in PXE chain.
#
# [*nameservers*]
#   Type: array, default: [ '8.8.8.8', '8.8.4.4' ]
#   Nameservers for kickstart files to put in resolv.conf upon
#   installation.
#
# [*dhcp_interfaces*]
#   Type: array, default: [ 'eth0' ]
#   Interface for DHCP to listen on.
#
# [*dhcp_subnets*]
#   Type: array, default: 
#   If you use *DHCP relay* on your network, then $dhcp_interfaces
#   won't suffice. $dhcp_subnets have to be defined, otherwise,
#   DHCP won't offer address to a machine in a network that's
#   not directly available on the DHCP machine itself.
#
# [*defaultrootpw*]
#   Type: string, default: $::osfamily based
#   Hash of root password for kickstart files.
#
# [*apache_service*]
#   Type: string, default: $::osfamily based
#   Name of the apache service.
#
# [*allow_access*]
#   Type: string, default: "${server_ip} ${::ipaddress} 127.0.0.1"
#   Allow access to cobbler_api from following IP addresses.
#
# [*purge_distro*]
# [*purge_repo*]
# [*purge_profile*]
# [*purge_system*]
#   Type: bool, default: false
#   Decides wether or not to purge (remove) distros, repos, profiles
#   and/or systems which are not managed by puppet.
#
# [*default_kickstart*]
#   Type: string, default: $::osfamily based
#   Location of the default kickstart file.
#
# [*webroot*]
#   Type: string, default: '/var/www/cobbler'
#   Location of Cobbler's web root.
#
# [*create_resources*]
#   Type: bool, default: false
#   Automatically create resources from hiera hashes.
#
# [*dependency_class*]
#   Type: string, default: ::cobbler::dependency
#   Name of a class that contains resources needed by this module but provided
#   by external modules. Set to undef to not include any dependency class.
#
# [*my_class*]
#   Type: string, default: undef
#   Name of a custom class to autoload to manage module's customizations
#
# [*noops*]
#   Type: boolean, default: undef
#   Set noop metaparameter to true for all the resources managed by the module.
#   If true no real change is done is done by the module on the system.
#
# === Requires
#
# - puppetlabs/apache class
#   (http://forge.puppetlabs.com/puppetlabs/apache)
#
# === Examples
#
#  include ::cobbler
#
# === Copyright
#
# Copyright 2014 Jakov Sosic <jsosic@gmail.com>
#
class cobbler (
  $service_name       = $::cobbler::params::service_name,
  $package_name       = $::cobbler::params::package_name,
  $package_ensure     = $::cobbler::params::package_ensure,
  $distro_path        = $::cobbler::params::distro_path,
  $manage_dhcp        = $::cobbler::params::manage_dhcp,
  $dhcp_dynamic_range = $::cobbler::params::dhcp_dynamic_range,
  $manage_dns         = $::cobbler::params::manage_dns,
  $dns_option         = $::cobbler::params::dns_option,
  $dhcp_option        = $::cobbler::params::dhcp_option,
  $manage_tftpd       = $::cobbler::params::manage_tftpd,
  $tftpd_option       = $::cobbler::params::tftpd_option,
  $server_ip          = $::cobbler::params::server_ip,
  $next_server_ip     = $::cobbler::params::next_server_ip,
  $nameservers        = [ '8.8.8.8', '8.8.4.4' ],
  $dhcp_interfaces    = [ 'eth0' ],
  $dhcp_subnets       = '',
  $defaultrootpw      = 'bettergenerateityourself',
  $apache_service     = $::cobbler::params::apache_service,
  $allow_access       = $::cobbler::params::allow_access,
  $purge_distro       = false,
  $purge_repo         = false,
  $purge_profile      = false,
  $purge_system       = false,
  $default_kickstart  = $::cobbler::params::default_kickstart,
  $webroot            = '/var/www/cobbler',
  $auth_module        = $::cobbler::params::auth_module,
  $create_resources   = false,
  $dependency_class   = '::cobbler::dependency',
  $my_class           = undef,
  $noops              = undef,
) inherits cobbler::params {

  # include dependencies
  if $::cobbler::dependency_class {
    include $::cobbler::dependency_class
  }

  # install section
  package { $::cobbler::params::tftp_package :
    ensure => present,
    noop   => $noops,
  }

  package { $::cobbler::params::syslinux_package :
    ensure => present,
    noop   => $noops,
  }

  package { 'cobbler':
    ensure  => $package_ensure,
    name    => $package_name,
    require => [ Package[$::cobbler::params::syslinux_package], Package[$::cobbler::params::tftp_package], ],
    noop    => $noops,
  }

  service { 'cobbler':
    ensure  => running,
    name    => $service_name,
    enable  => true,
    require => [ Package['cobbler'], File["${distro_path}/kickstarts"] ],
    noop    => $noops,
  }

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
    notify  => Service['httpd'],
  }

  file { $distro_path :
    ensure => directory,
    mode   => '0755',
  }

  file { "${distro_path}/kickstarts" :
    ensure => directory,
    mode   => '0755',
  }

  file { '/etc/cobbler/settings':
    content => template('cobbler/settings.erb'),
    require => Package['cobbler'],
    notify  => Service['cobbler'],
  }

  file { '/etc/cobbler/modules.conf':
    content => template('cobbler/modules.conf.erb'),
    require => Package['cobbler'],
    notify  => Service['cobbler'],
  }

  file { "${::cobbler::params::http_config_prefix}/distros.conf": content => template('cobbler/distros.conf.erb'), }
  file { "${::cobbler::params::http_config_prefix}/cobbler.conf": content => template('cobbler/cobbler.conf.erb'), }

  # cobbler sync command
  exec { 'cobblersync':
    command     => '/usr/bin/cobbler sync',
    refreshonly => true,
    require     => [ Service['cobbler'], Service['httpd'] ],
  }

  # resource defaults
  resources { 'cobblerdistro':
    purge   => $purge_distro,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
  }
  }
  resources { 'cobblerrepo':
    purge   => $purge_repo,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
  }
  resources { 'cobblerprofile':
    purge   => $purge_profile,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
  }
  resources { 'cobblersystem':
    purge   => $purge_system,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
  }

  # create resources from hiera
  if ( $create_resources == true ) {
    create_resources(cobblerdistro,  hiera_hash('cobbler::distros',  {}) )
    create_resources(cobblerrepo,    hiera_hash('cobbler::repos',    {}) )
    create_resources(cobblerprofile, hiera_hash('cobbler::profiles', {}) )
    create_resources(cobblersystem,  hiera_hash('cobbler::systems',  {}) )
  }

  # include ISC DHCP only if we choose manage_dhcp
  if $manage_dhcp == '1' and $dhcp_option == 'isc' {
    include ::cobbler::dhcp
  }

  # logrotate script
  file { '/etc/logrotate.d/cobbler':
    source => 'puppet:///modules/cobbler/logrotate',
  }
}
# vi:nowrap:
