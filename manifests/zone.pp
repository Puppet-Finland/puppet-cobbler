#
# == Define: cobbler::zone
#
# Manage Cobbler's Bind DNS zone templates
#
# == Parameters
#
# [*records*]
#   A list of strings containing DNS records in the format Bind expect them. For
#   example ['puppet.internal.domain.com.  IN  A  10.249.0.1;'].
#
define cobbler::zone
(
    Array[String] $records = []
)
{
  include ::cobbler::params

  file { "cobbler-zone-${title}":
    name    => "/etc/cobbler/zone_templates/${title}",
    content => template('cobbler/zone_template.erb'),
    owner   => $::os::params::adminuser,
    group   => $::os::params::admingroup,
    mode    => '0644',
    require => Class['::cobbler::install'],
  }
}
