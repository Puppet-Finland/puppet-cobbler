#
# = Class: cobbler::dependency
#
# Loads standard dependencies that class 'cobbler' requires.
class cobbler::dependency {

  # require apache modules
  include ::apache
  include ::apache::mod::wsgi
  include ::apache::mod::proxy
  include ::apache::mod::proxy_http
  include ::apache::mod::setenvif

  # The selinux settings need to be tweaked before we attempt to integrate 
  # Cobbler with it.
  if $::selinux {
    include ::selinux

    $cobbler_booleans = [ 'cobbler_can_network_connect',
                          'httpd_can_network_connect_cobbler',
                          'httpd_serve_cobbler_files', ]

    selboolean { $cobbler_booleans:
      value      => on,
      persistent => true,
      require    => Class['apache'],
    }

    selinux::module { 'cobblerlocal':
        modulename => 'cobbler',
    }
  }
}
