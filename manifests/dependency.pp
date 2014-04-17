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

}
