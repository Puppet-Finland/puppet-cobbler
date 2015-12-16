#
# = Class: cobbler::web::dependency_class
#
# Loads standard dependencies that class 'cobbler' requires.
class cobbler::web::dependency_class {

  # require apache modules
  #
  # FIXME: this class is missing from Puppet-Finland
  include ::apache2::config::ssl

}
