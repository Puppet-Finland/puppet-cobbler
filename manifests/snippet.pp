#
# == Define: cobbler::snippet
#
# Install a Cobbler kickstart snippet
#
# == Parameters
#
# [*title*]
#   The resource title is used as the snippet source/destination filename. The 
#   source file should be on the Puppet fileserver at files share named as 
#   cobbler-snippet-$title.
#
define cobbler::snippet
(
    Enum['present','absent'] $ensure = 'present'
)
{
    file { "cobbler-snippet-${title}":
        ensure  => $ensure,
        name    => "/var/lib/cobbler/snippets/${title}",
        source  => "puppet:///files/cobbler-snippet-${title}",
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0644',
        require => Class['::cobbler::install'],
    }
}
