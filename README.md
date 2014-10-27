# cobbler

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with cobbler](#setup)
    * [What cobbler affects](#what-cobbler-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cobbler](#beginning-with-cobbler)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Modifying defaults](#what-cobbler-affects)
    * [Cobbler distro](#cobblerdistro)
    * [Cobbler repo](#cobblerrepo)
    * [Cobbler profile](#cobblerprofile)
    * [Cobbler system](#cobblersystem)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
    * [Contributing](#contributing)

## Overview

Cobbler module allows you to set up Cobbler and add distros, repos, profiles and systems
with minimal effort.

## Module Description

Cobbler is a Linux installation server that allows for rapid setup of network installation
environments. This module provides a simplified way of setting up Cobbler, and later
managing internal Cobbler resources like distros and systems. Module helps in a way that
allows you to visualise configuration of distros/repos/profiles/systems via puppet code
instead of remembering long and cumbersome CLI commands.

## Setup

### What cobbler affects

* configuration files and directories (contents of /etc/cobbler)
* internal Cobbler database entries (distro, repo, profile, system)

### Setup requirements

Some functionality is dependent on other modules:
* [apache](http://forge.puppetlabs.com/puppetlabs/apache)

### Beginning with cobbler

To install Cobbler with the default parameters, just define class:

```puppet
    include ::cobbler
```

To set up cobbler web management interface:

```puppet
    include ::cobbler::web
```

## Usage

### Modifying defaults

Defaults are determined depending on operating system. This action will install cobbler, tftp and syslinux. It will use PuppetLabs-Apache module to set up Apache with mod_wsgi, and to set up /cobbler context
and /distros context in Apache. If you wish to mangle with parameters, you can do it using hiera, for example:

```yaml
    cobbler::distro_path     : '/data/distro'
    cobbler::manage_dhcp     : 1
    cobbler::server_ip       : '10.100.0.111'
    cobbler::next_server_ip  : '10.100.0.111'
    cobbler::allow_access    : '10.100.0.111 127.0.0.1'
    cobbler::dhcp::nameservers   : - '10.100.0.112'
                                   - '10.100.0.113'
    cobbler::dhcp::dynamic_range : 1
    cobbler::dhcp::subnets: - '10.100.0.0/255.255.0.0'
                            - '10.200.0.0/255.255.0.0'
    cobbler::purge_profile: True
    cobbler::purge_system:  True
```

### Cobbler distro

Distro is an object in Cobbler representing Linux distribution, with its own kernel, installation and packages.

You can easily add distros to your Cobbler installation just by specifying download link of ISO image and distro name:

```puppet
    cobbler::add_distro { 'CentOS-6.5-x86_64':
      arch    => 'x86_64',
      isolink => 'http://mi.mirror.garr.it/mirrors/CentOS/6.5/isos/x86_64/CentOS-6.5-x86_64-bin-DVD1.iso',
    }

If you want to use 'cobbler import' style, you can add a distro other way:

```puppet
    cobblerdistro { 'SL-6.5-x86_64':
      ensure  => present,
      path    => '/distro/SL64/x86_64/os',
      ks_meta => {
       'tree' => 'http://repos.theory.phys.ucl.ac.uk/mirrors/SL/6.5/x86_64/os',
      },
    }
```

ks_meta's parameter's 'tree' value is used as '--available-as' option.

### Cobbler repo

Repo is an Cobbler object representing a distribution package repository (for example yum repo).

If you wish to mirror additional repositories for your kickstart installations, it's as easy as:

```puppet
    cobblerrepo { 'PuppetLabs-6-x86_64-deps':
      ensure         => present,
      arch           => 'x86_64',
      mirror         => 'http://yum.puppetlabs.com/el/6/dependencies/x86_64',
      mirror_locally => false,
      priority       => 99,
      require        => [ Service[$cobbler::service_name], Service[$cobbler::apache_service] ],
    }
```

### Cobbler profile

Profile is an Cobbler object representing a pre-configured set of distro/repos/settings for kickstarting a node.

Simple profile definition looks like:

```puppet
    cobblerprofile { 'CentOS-6.5-x86_64':
      ensure      => present,
      distro      => 'CentOS-6.5-x86_64',
      nameservers => $cobbler::nameservers,
      repos       => ['PuppetLabs-6-x86_64-deps', 'PuppetLabs-6-x86_64-products' ],
      kickstart   => '/somepath/kickstarts/CentOS-6.5-x86_64-static.ks',
    }
```

### Cobbler system

System is an Cobbler object representing a single node that can be kickstarted.

Typical definition looks like:

```puppet
    cobblersystem { 'somehost':
      ensure     => present,
      profile    => 'CentOS-6.5-x86_64',
      interfaces => { 'eth0' => {
                        mac_address      => 'AA:BB:CC:DD:EE:F0',
                        interface_type   => 'bond_slave',
                        interface_master => 'bond0',
                        static           => true,
                        management       => true,
                      },
                      'eth1' => {
                        mac_address      => 'AA:BB:CC:DD:EE:F1',
                        interface_type   => 'bond_slave',
                        interface_master => 'bond0',
                        static           => true,
                      },
                      'bond0' => {
                        ip_address     => '192.168.1.210',
                        netmask        => '255.255.255.0',
                        static         => true,
                        interface_type => 'bond',
                        bonding_opts   => 'miimon=300 mode=1 primary=em1',
                      },
      },
      netboot    => true,
      gateway    => '192.168.1.1',
      hostname   => 'somehost.example.com',
      require    => Service[$cobbler::service_name],
    }
```


## Reference

TODO

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

### Contributing

Cobbler module Forge is open project, and community contributions are welcome.

## Contributors

* jsosic (jsosic@gmail.com) - original author
* igalic (i.galic@brainsware.org) - advancement in virtual environments and Debian based support
