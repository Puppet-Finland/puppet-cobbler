#
# == Define: cobbler::kickstart
#
# Manage kickstart/preseed files in Cobbler
#
# == Parameters
#
# [*title*]
#   The resource $title is used as the source and target filename. The source 
#   file must be present on the Puppet fileserver.
# [*ensure*]
#   The state of the kickstart file. Valid values are 'present' and 'absent'.
# [*publish*]
#   Place the kickstart/preseed file to its webserver 
#   at http://<server>/cobbler/ks_mirror/<title>. Valid values are true and
#   false (default).
#
define cobbler::kickstart
(
    $ensure = 'present',
    Boolean $publish = false
)
{
    validate_string($title)
    validate_re($ensure, ['^present$', '^absent$'])

    File {
        ensure  => $ensure,
        source  => "puppet:///files/${title}",
        owner   => root,
        group   => root,
        mode    => '0644',
        require => Class['cobbler::install'],
    }

    file { "cobbler-kickstart-${name}":
        name => "/var/lib/cobbler/kickstarts/${title}",
    }

    if $publish {
        file { "cobbler-kickstart-public-${name}":
            name => "/var/www/cobbler/ks_mirror/${title}",
        }
    }
}
