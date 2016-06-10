# cobbler

## Overview

Cobbler module allows you to set up Cobbler and add distros, repos, profiles and systems
with minimal effort.

## Module Description

Cobbler is a Linux installation server that allows for rapid setup of network 
installation environments. This module provides a simplified way of setting up 
Cobbler, and later managing internal Cobbler resources like distros and systems. 
This module helps in a way that allows you to visualise configuration of 
distros/repos/profiles/systems via puppet code instead of remembering long and 
cumbersome CLI commands.

The module modifies various aspects of the system:

* configuration files and directories (contents of /etc/cobbler)
* internal Cobbler database entries (distro, repo, profile, system)

This module also support configuring Koan, so that you can use Cobbler to 
bootstrap virtual machines.

## Usage

Some functionality is dependent on other modules. See metadata.json for details 
and make sure all the dependencies are in place.

While the module has relative sane defaults for the class parameters, it usually 
makes sense to make them explicit. Here's an example:

```yaml
    classes:
        - cobbler
    
    cobbler::distro_path: '/distros'
    cobbler::manage_dhcp: true
    cobbler::manage_dns: true
    cobbler::dns_option: 'bind'
    cobbler::manage_tftp: true
    cobbler::server_ip: '10.249.0.1'
    cobbler::next_server_ip: '10.249.0.1'
    cobbler::nameservers:
        - '10.249.0.1'
    cobbler::dhcp_interfaces:
        - 'br0'
    cobbler::dhcp_netmask: '255.255.0.0'
    cobbler::dhcp_dynamic_range: true
    cobbler::defaultrootpw: <password-hash>
    cobbler::allow_access: '127.0.0.1 10.249.0.1'
```

If you want to purge unmanaged cobbler resources, use the purge parameters:

```yaml
    cobbler::purge_distro: true
    cobbler::purge_repo: true
    cobbler::purge_profile: true
    cobbler::purge_system: true
```

You can also manage DNS zones using Cobbler's zone templates:

```yaml
    cobbler::dns_forward_zones:
        - 'internal.domain.com'
    cobbler::dns_reverse_zones:
        - '10.249.0'
    
    cobbler::zones:
        internal.domain.com:
            records:
                - 'cobbler.internal.domain.com. IN   A   10.249.0.1;'
                - 'backup.internal.domain.com.  IN   A 10.249.0.2;'
```

Defining the address of the Cobbler server as a static DNS record (like above) 
is necessary if you want to refer to its DNS name in kickstarts.

If you intend to use Cobbler with Koan/libvirt, you should have additional 
configurations in place:

```yaml
    classes:
        - cobbler::koan
        - libvirt
        
    libvirt::allow_port: '5900-5920'
    libvirt::allow_user:
        - 'john'
        - 'jane'
    libvirt::networks:
        default:
            ensure: 'absent'
    libvirt::service_ensure: 'running'
    libvirt::vnc_listen: '0.0.0.0'
```

### Cobbler distro

Distro is an object in Cobbler representing Linux distribution, with its own kernel, installation and packages.

You can easily add distros to your Cobbler installation just by specifying download link of ISO image and distro name:

```yaml
    cobbler::distros:
        CentOS-7.2-x86_64:
            ensure: 'present'
            breed: 'redhat'
            os_version: 'rhel7'
            arch: 'x86_64'
            isolink: 'http://ftp.funet.fi/pub/linux/mirrors/centos/7.2.1511/isos/x86_64/CentOS-7-x86_64-Minimal-1511.iso'
            kernel: '/distros/CentOS-7.2-x86_64/isolinux/vmlinuz'
            initrd: '/distros/CentOS-7.2-x86_64/isolinux/initrd.img'
            destdir: '/distros'
            ks_meta:
                tree: 'http://@@http_server@@/cblr/links/CentOS-7.2-x86_64'
```
The ks_meta's parameter's 'tree' value is used as '--available-as' option.

If you want to use 'cobbler import' style, you use the path parameter to the 
cobblerdistro resource.

### Cobbler repo

Repo is an Cobbler object representing a distribution package repository (for example yum repo).

If you wish to mirror additional repositories for your kickstart installations, it's as easy as:

```yaml
    cobbler::repos:
        puppetlabs-pc1:
            ensure         : present
            mirror         : 'http://yum.puppetlabs.com/el/7/PC1/x86_64'
            mirror_locally : false
            priority       : 99
```

### Cobbler profile

Profile is an Cobbler object representing a pre-configured set of distro/repos/settings for kickstarting a node.

Simple profile definition for Koan virtual machines looks like this:

```yaml
    cobbler::profiles:
        centos7:
            comment:          'CentOS 7.2 virtual machine'
            ensure:           'present'
            distro:           'CentOS-7.2-x86_64'
            kickstart:        '/var/lib/cobbler/kickstarts/centos7.ks'
            repos:
                - 'puppetlabs-pc1'
            virt_auto_boot:   true
            virt_type:        'kvm'
            virt_cpus:        1
            virt_ram:         768
            virt_file_size:   10
            virt_bridge:      'br0'
```

### Cobbler system

System is an Cobbler object representing a single node that can be kickstarted.

Typical definition looks like:

```yaml
    cobbler::systems:
        'www.internal.domain.com':
            name:       'www.internal.domain.com'
            ensure:     'present'
            hostname:   'www.internal.domain.com'
            comment:    'Website for our company'
            profile:    'centos7'
            netboot:    false
            interfaces:  
                'eth0':
                    mac_address: '00:16:3e:01:b5:07'
                    static:      false
                    management:  false
```

## Cobbler snippet

Simple static snippets can be added to the Puppet fileserver:

```yaml
    cobbler::snippets:
        setup_puppet_agent: {}
```

The files need to accessible under the URL puppet:///files/ and must be prefixed 
with "cobbler-snippet-". In this case the full filename would be 
"cobbler-snippet-setup_puppet_agent".

## Cobbler kickstarts

These work essentially the same as snippets, above, except that the file prefix 
is "cobbler-kickstart-":

```yaml
    cobbler::kickstarts:
        centos7.ks: {}
```

## Operating system support

This module has been tested on CentOS 7 and Cobbler 2.6. Earlier versions of 
this module claimed support for CentOS 5/6 and Ubuntu 12.04/14.04, but the 
module has been heavily refactored and modified since then.

## Development

### Contributing

Cobbler module Forge is open project, and community contributions are welcome.

## Contributors

* jsosic (jsosic@gmail.com) - original author
* igalic (i.galic@brainsware.org) - advancement in virtual environments and Debian based support
* mattock (samuli.seppanen@gmail.com) - general cleanup, heavy refactoring and various improvements
