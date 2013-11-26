#
# = Class: cobbler::web::dependency_class
#
# Loads standard dependencies that class 'cobbler' requires.
class cobbler::web::dependency_class {

  # require apache modules
  include ::apache::mod::ssl

}
