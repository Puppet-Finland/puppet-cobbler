# Class: cobbler
#
# This class manages Cobbler
# https://fedorahosted.org/cobbler/
#
# Parameters:
#
#   - $service_name [type: string]
#     Name of the cobbler service, defaults to 'cobblerd'.
#
#   - $package_name [type: string]
#     Name of the installation package, defaults to 'cobbler'
#
#   - $package_ensure [type: string]
#     Defaults to 'present', buy any version can be set
#
#   - $distro_path [type: string]
#     Defines the location on disk where distro files will be
#     stored. Contents of the ISO images will be copied over
#     in these directories, and also kickstart files will be
#     stored. Defaults to '/distro'
#
#   - $manage_dhcp [type: bool]
#     Wether or not to manage ISC DHCP.
#
#   - $dhcp_dynamic_range [type: string]
#     Range for DHCP server
#
#   - $manage_dns [type: string]
#     Wether or not to manage DNS
#
#   - $dns_option [type: string]
#     Which DNS deamon to manage - Bind or dnsmasq. If dnsmasq,
#     then dnsmasq has to be used for DHCP too.
#
#   - $manage_tftpd [type: bool]
#     Wether or not to manage TFTP daemon.
#
#   - $tftpd_option [type:string]
#     Which TFTP daemon to use.
#
#   - $server_ip [type: string]
#     IP address of a server.
#
#   - $next_server_ip [type: string]
#     Next Server in cobbler config.
#
#   - $nameservers [type: array]
#     Nameservers for kickstart files to put in resolv.conf upon
#     installation.
#
#   - $dhcp_interfaces [type: array]
#     Interface for DHCP to listen on.
#
#   - $dhcp_subnets [type: array]
#     If you use *DHCP relay* on your network, then $dhcp_interfaces
#     won't suffice. $dhcp_subnets have to be defined, otherwise,
#     DHCP won't offer address to a machine in a network that's
#     not directly available on the DHCP machine itself.
#
#   - $defaultrootpw [type: string]
#     Hash of root password for kickstart files.
#
#   - $apache_service [type: string]
#     Name of the apache service.
#
#   - $allow_access [type: string]
#     For what IP addresses/hosts will access to cobbler_api be granted.
#     Default is for server_ip, ::ipaddress and localhost
#
#   - $purge_distro  [type: bool]
#   - $purge_repo    [type: bool]
#   - $purge_profile [type: bool]
#   - $purge_system  [type: bool]
#     Decides wether or not to purge (remove) from cobbler distro,
#     repo, profiles and systems which are not managed by puppet.
#     Default is false.
#
#   - default_kickstart [type: string]
#     Location of the default kickstart. Default depends on $::osfamily.
#
#   - webroot [type: string]
#     Location of Cobbler's web root. Default: '/var/www/cobbler'.
#
#   - create_resources [type: bool]
#     Automatically create resources from hiera hashes. Default: false
#
# Actions:
#   - Install Cobbler
#   - Manage Cobbler service
#
# Requires:
#   - puppetlabs/apache class
#     (http://forge.puppetlabs.com/puppetlabs/apache)
#
# Sample Usage:
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
  $nameservers        = $::cobbler::params::nameservers,
  $dhcp_interfaces    = $::cobbler::params::dhcp_interfaces,
  $dhcp_subnets       = $::cobbler::params::dhcp_subnets,
  $defaultrootpw      = $::cobbler::params::defaultrootpw,
  $apache_service     = $::cobbler::params::apache_service,
  $allow_access       = $::cobbler::params::allow_access,
  $purge_distro       = false,
  $purge_repo         = false,
  $purge_profile      = false,
  $purge_system       = false,
  $default_kickstart  = $::cobbler::params::default_kickstart,
  $webroot            = $::cobbler::params::webroot,
  $auth_module        = $::cobbler::params::auth_module,
  $create_resources   = false,
  $dependency_class   = $::cobbler::params::dependency_class,
) inherits cobbler::params {

  # include dependencies
  if $::cobbler::dependency_class {
    include $::cobbler::dependency_class
  }

  # install section
  package { $::cobbler::params::tftp_package:     ensure => present, }
  package { $::cobbler::params::syslinux_package: ensure => present, }
  package { $package_name:
    ensure  => $package_ensure,
    require => [ Package[$::cobbler::params::syslinux_package], Package[$::cobbler::params::tftp_package], ],
  }

  service { $service_name :
    ensure  => running,
    enable  => true,
    require => Package[$package_name],
  }

  # file defaults
  File {
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
  }
  file { "${::cobbler::params::proxy_config_prefix}/proxy_cobbler.conf":
    content => template('cobbler/proxy_cobbler.conf.erb'),
    notify  => Service[$apache_service],
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
    require => Package[$package_name],
    notify  => Service[$service_name],
  }
  file { '/etc/cobbler/modules.conf':
    content => template('cobbler/modules.conf.erb'),
    require => Package[$package_name],
    notify  => Service[$service_name],
  }
  file { "${::cobbler::params::http_config_prefix}/distros.conf": content => template('cobbler/distros.conf.erb'), }
  file { "${::cobbler::params::http_config_prefix}/cobbler.conf": content => template('cobbler/cobbler.conf.erb'), }

  # cobbler sync command
  exec { 'cobblersync':
    command     => '/usr/bin/cobbler sync',
    refreshonly => true,
  }

  # resource defaults
  resources { 'cobblerdistro':
    purge   => $purge_distro,
    require => [ Service[$::cobbler::service_name], Service[$::cobbler::apache_service] ],
  }
  resources { 'cobblerrepo':
    purge   => $purge_repo,
    require => [ Service[$::cobbler::service_name], Service[$::cobbler::apache_service] ],
  }
  resources { 'cobblerprofile':
    purge   => $purge_profile,
    require => [ Service[$::cobbler::service_name], Service[$::cobbler::apache_service] ],
  }
  resources { 'cobblersystem':
    purge   => $purge_system,
    require => [ Service[$::cobbler::service_name], Service[$::cobbler::apache_service] ],
  }

  # create resources from hiera
  if ( $create_resources == true ) {
    create_resources(cobblerdistro,  hiera_hash('cobbler::distros',  {}) )
    create_resources(cobblerrepo,    hiera_hash('cobbler::repos',    {}) )
    create_resources(cobblerprofile, hiera_hash('cobbler::profiles', {}) )
    create_resources(cobblersystem,  hiera_hash('cobbler::systems',  {}) )
  }

  # include ISC DHCP only if we choose manage_dhcp
  if $manage_dhcp == '1' {
    include ::cobbler::dhcp
  }

  # logrotate script
  file { '/etc/logrotate.d/cobbler':
    source => 'puppet:///modules/cobbler/logrotate',
  }
}
# vi:nowrap:
