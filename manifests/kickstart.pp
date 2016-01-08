#
# == Define: cobbler::kickstart
#
# Manage kickstart files in Cobbler
#
# == Parameters
#
# [*title*]
#   The resource $title is used as the source and target filename. The source 
#   file must be present on the Puppet fileserver.
# [*ensure*]
#   The state of the kickstart file. Valid values are 'present' and 'absent'.
#
define cobbler::kickstart
(
    $ensure = 'present'
)
{
    validate_string($title)
    validate_re($ensure, ['^present$', '^absent$'])

    file { "cobbler-kickstart-${name}":
        ensure  => $ensure,
        name    => "/var/lib/cobbler/kickstarts/${title}",
        source  => "puppet:///files/${title}",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Class['cobbler::install'],
    }
}
