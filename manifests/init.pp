#
# == Class: cobbler
#
# This class manages Cobbler ( http://www.cobblerd.org/ )
#
# === Parameters
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
#   Whether or not to manage ISC DHCP.
#
# [*dhcp_option*]
#   Type: string, default 'isc'
#   Which DHCP server to use. Valid values are 'isc' and 'dnsmasq'.
#
# [*dhcp_dynamic_range*]
#   Type: boolean, default: false
#   Hand out dynamic IP addresses from the DHCP server. The dynamic address 
#   range will be 100-200.
#
# [*dhcp_netmask*]
#   Netmask for the DHCP subnet. Defaults to '255.255.255.0'.
#
# [*dhcp_router]
#   The router to advertise via DHCP. This defaults to the IP of each DHCP 
#   interface. Note that if this parameter is defined manually, the same value 
#   is used on every subnet. This a limitation in this module and 
#   dhcp.template.erb in particular.
#
# [*manage_dns*]
#   Type: bool, default: false
#   Wether or not to manage DNS
#
# [*dns_option*]
#   Type: string, default: 'dnsmasq'
#   Which DNS deamon to manage - 'bind' or 'dnsmasq'. If 'dnsmasq', then
#   dnsmasq has to be used for DHCP too.
#
# [*manage_tftpd*]
#   Type: bool, default: true
#   Wether or not to manage TFTP daemon.
#
# [*tftpd_option*]
#   Type: string, default: 'in_tftpd'
#   Which TFTP daemon to use. Only valid value for now is 'in_tftpd'.
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
#   Type: array, default: undef
#   If you use *DHCP relay* on your network, then $dhcp_interfaces
#   won't suffice. $dhcp_subnets have to be defined, otherwise,
#   DHCP won't offer address to a machine in a network that's
#   not directly available on the DHCP machine itself.
#
# [*defaultrootpw*]
#   Type: string, default: $::osfamily based
#   Hash of root password for kickstart files.
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
# [*auth_module*]
#   Type: string, default 'authn_denyall'.
#   Use authentication module that determines who can log into the WebUI and 
#   read and write XMLRPC. See templates/modules.conf.erb for the options and 
#   their descriptions.
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
# [*distros*]
#   A hash of cobblerdistro resources to realize.
# [*repos*]
#   A hash of cobblerrepo resources to realize.
# [*profiles*]
#   A hash of cobblerprofile resources to realize.
# [*systems*]
#   A hash of cobblersystem resources to realize.
# [*kickstarts*]
#   A hash of cobbler::kickstart resources to realize.
# [*snippets*]
#   A hash of cobbler::snippet resources to realize.
#
# === Examples
#
#  include ::cobbler
#
# === Copyright
#
# Copyright 2014 Jakov Sosic <jsosic@gmail.com>
#
# Copyright 2015 Samuli Seppänen <samuli.seppanen@gmail.com>
#
class cobbler (
  $distro_path        = $::cobbler::params::distro_path,
  $manage_dhcp        = false,
  $dhcp_dynamic_range = false,
  $dhcp_netmask       = '255.255.255.0',
  $dhcp_router        = undef,
  $manage_dns         = false,
  $dns_option         = 'dnsmasq',
  $dhcp_option        = 'isc',
  $manage_tftpd       = true,
  $tftpd_option       = 'in_tftpd',
  $server_ip          = $::cobbler::params::server_ip,
  $next_server_ip     = $::cobbler::params::next_server_ip,
  $nameservers        = [ '8.8.8.8', '8.8.4.4' ],
  $dhcp_interfaces    = [ 'eth0' ],
  $dhcp_subnets       = undef,
  $defaultrootpw      = 'bettergenerateityourself',
  $allow_access       = $::cobbler::params::allow_access,
  $purge_distro       = false,
  $purge_repo         = false,
  $purge_profile      = false,
  $purge_system       = false,
  $default_kickstart  = $::cobbler::params::default_kickstart,
  $webroot            = '/var/www/cobbler',
  $auth_module        = 'authn_denyall',
  $dependency_class   = '::cobbler::dependency',
  $my_class           = undef,
  $noops              = undef,
  $distros            = {},
  $repos              = {},
  $profiles           = {},
  $systems            = {},
  $kickstarts         = {},
  $snippets           = {}

) inherits cobbler::params {

  # Validate parameters that are used in this class
  validate_hash($distros)
  validate_hash($repos)
  validate_hash($profiles)
  validate_hash($systems)
  validate_hash($kickstarts)
  validate_hash($snippets)
  validate_bool($manage_dhcp)
  validate_re($dhcp_option, ['^isc$', '^dnsmasq$'])

  # Some parameters are optional and should only be validated if they have been 
  # defined
  if $noops { validate_bool($noops) }

  # include dependencies
  if $::cobbler::dependency_class {
    include $::cobbler::dependency_class
  }

  class { '::cobbler::install':
    noops          => $noops,
  }

  class { '::cobbler::config':
    distro_path        => $distro_path,
    manage_dhcp        => $manage_dhcp,
    dhcp_dynamic_range => $dhcp_dynamic_range,
    manage_dns         => $manage_dns,
    dns_option         => $dns_option,
    dhcp_option        => $dhcp_option,
    manage_tftpd       => $manage_tftpd,
    tftpd_option       => $tftpd_option,
    server_ip          => $server_ip,
    next_server_ip     => $next_server_ip,
    nameservers        => $nameservers,
    dhcp_interfaces    => $dhcp_interfaces,
    dhcp_subnets       => $dhcp_subnets,
    defaultrootpw      => $defaultrootpw,
    allow_access       => $allow_access,
    default_kickstart  => $default_kickstart,
    webroot            => $webroot,
    auth_module        => $auth_module,
    noops              => $noops,
  }

  class { '::cobbler::service':
    distro_path => $distro_path,
    noops       => $noops,
  }

  # Cobbler resource defaults
  resources { 'cobblerdistro':
    purge   => $purge_distro,
    require => [ Service['cobbler'], Service['httpd'] ],
    noop    => $noops,
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

  # Create Cobbler resources from hashes passed as parameters
  $defaults = { 'require' => Class['cobbler::service'] }

  create_resources(cobblerdistro,  $distros,  $defaults)
  create_resources(cobblerrepo,    $repos,    $defaults)
  create_resources(cobblerprofile, $profiles, $defaults)
  create_resources(cobblersystem,  $systems,  $defaults)
  create_resources('cobbler::kickstart', $kickstarts)
  create_resources('cobbler::snippet', $snippets)

  # include ISC DHCP only if we choose manage_dhcp
  if $manage_dhcp and $dhcp_option == 'isc' {
    class { '::cobbler::dhcp':
      nameservers   => $nameservers,
      interfaces    => $dhcp_interfaces,
      netmask       => $dhcp_netmask,
      subnets       => $dhcp_subnets,
      dynamic_range => $dhcp_dynamic_range,
      router        => $dhcp_router,
    }
  }
}
