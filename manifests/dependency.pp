#
# = Class: cobbler::dependency
#
# Loads standard dependencies that class 'cobbler' requires.
class cobbler::dependency {

  # require apache modules
  include ::apache2
  include ::apache2::config::wsgi
  include ::apache2::config::proxy
  include ::apache2::config::proxy_http
  include ::apache2::config::setenvif

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
      require    => Class['::apache2'],
    }

    selinux::module { 'cobblerlocal':
        modulename => 'cobbler',
    }
  }
}
