#
# = Define: cobbler::del_distro
#
# Deletes cobblerdistro and it's kickstart
define cobbler::del_distro (){
  include ::cobbler

  $distro = $title
  cobblerdistro { $distro :
    ensure  => absent,
    destdir => $cobbler::distro_path,
    require => [ Service['cobbler'], Service['httpd'] ],
  }
  file { "${::cobbler::config::webroot}/links/${distro}":
    ensure  => 'absent',
  }
  file { "${cobbler::distro_path}/kickstarts/${distro}.ks":
    ensure  => absent,
  }
}
