#
# == Class: cobbler::koan
#
# Install Koan for bootstrapping virtual machines using Cobbler
#
class cobbler::koan inherits cobbler::params {

    # Koan has not been updated to latest virt-install API, so we need to 
    # forcibly downgrade virt-install and virt-manager-common
    #
    if ( $::operatingsystem == 'CentOS' ) and ( $::operatingsystemmajrelease == '7' ) {

        yumrepo { 'vault':
            descr    => 'Obsolete yum packages',
            baseurl  => 'http://vault.centos.org/7.0.1406/os/x86_64',
            enabled  => 1,
            gpgcheck => 1,
            gpgkey   => 'http://vault.centos.org/RPM-GPG-KEY-CentOS-6',
        }

        exec { 'cobbler-downgrade-virt-install':
            user    => root,
            command => 'yum -y downgrade http://vault.centos.org/7.0.1406/os/x86_64/Packages/virt-install-0.10.0-20.el7.noarch.rpm http://vault.centos.org/7.0.1406/os/x86_64/Packages/virt-manager-common-0.10.0-20.el7.noarch.rpm',
            path    => ['/bin', '/usr/bin'],
            unless  => 'virt-install --version 2>&1|grep \'0.10.0\'',
            require => Yumrepo['vault'],
        }
    }

    package { 'cobbler-koan':
        ensure => present,
        name   => 'koan',
    }
}
