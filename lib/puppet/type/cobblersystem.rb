Puppet::Type.newtype(:cobblersystem) do
@doc = "Manages the Cobbler system

A typical rule will look like this:

cobblersystem { 'test.domain.com':
  ensure         => present,
  profile        => 'CentOS-6.3-x86_64',
  interfaces     => { 
    'eth0' => {
      mac_address => '90:B1:1C:06:BF:56',
      static      => true,
      management  => true,
      ip_address  => '10.8.16.53',
      netmask     => '255.255.255.0',
      dns_name    => 'test.domain.com',
    },
  },
  kernel_options => {
    kssendmac => '~',
    noacpi    => '~',
    selinux   => 'permissive',
  },
  gateway        => '10.8.16.51',
  hostname       => 'test.domain.com',
  netboot        => false,
  comment        => 'my system description',
}

"
  desc 'The cobbler system type'

  ensurable

  newparam(:name) do
    isnamevar
    desc 'The name of the system'
  end

  newproperty(:profile) do
    desc 'Profile that is linked with system'
  end

  autorequire(:cobblerprofile) do
    self[:profile]
  end

  newproperty(:interfaces) do
    desc 'The list of interfaces in system.'

    def insync?(is)
      # @should is an Array. see lib/puppet/type.rb insync?
      should = @should.first

      # if members of hashes are not the same, something
      # was added or removed from manifest, so return false
      return false unless is.class == Hash and should.class == Hash and is.keys.sort == should.keys.sort
      # check if something was added or removed on second level
      is.each do |is_key,is_value|
        if is_value.is_a?(Hash)
          # hack for 'management' setting (which is being read all the time)
          should[is_key]['management'] = false unless should[is_key].has_key?('management')
          # check every key in puppet manifest, leave the rest
          should[is_key].keys.uniq.each do |key|
            return false unless should[key].to_s != is_value[key].to_s
          end
        end
      end
      # if some setting changed in manifest, return false
      should.each do |k, v|
        if v.is_a?(Hash)
          v.each do |l, w|
            unless is[k][l].nil? 
               return false unless is[k][l].to_s == w.to_s
            end
          end 
        end 
      end 
      true
    end 

    def should_to_s(newvalue)
      newvalue.inspect
    end 

    def is_to_s(currentvalue)
      currentvalue.inspect
    end 
  end 

  newproperty(:kernel_options) do
    desc "Kernel options for installation boot."
    defaultto Hash.new

    def insync?(is)
      # @should is an Array. see lib/puppet/type.rb insync?
      should = @should.first

      # if members of hashes are not the same, something
      # was added or removed from manifest, so return false
      return false unless is.class == Hash and should.class == Hash and is.keys.sort == should.keys.sort
      # check if values of hash keys are equal
      is.each do |l,w|
        return false unless w.to_s == should[l].to_s
      end
      true
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end 

  newproperty(:gateway) do
    desc 'IP address of gateway.'
    defaultto ''
    validate do |value|
      unless value.chomp.empty?
        raise ArgumentError, "%s is not a valid IP address." % value unless value =~ /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}/
      end
    end
  end

  newproperty(:hostname) do
    desc 'The hostname of the system, can be equal to name'
    defaultto { @resource[:name] }
    validate do |value|
      unless value.chomp.empty?
        raise ArgumentError, "%s is not a valid hostname." % value unless value =~ /^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-_]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-_]*[A-Za-z0-9])$/
      end
    end
  end

  newproperty(:netboot) do
    desc 'Enable reinstallation of system.'
    newvalues(:true, :false)
  end

  newproperty(:comment) do
    desc 'Human readable description of this system.'
  end

  newproperty(:power_type) do
    desc 'Power Management Type (Power management script to use)'
  end

  newproperty(:virt_auto_boot) do
    desc 'Virt Auto Boot (Auto boot this VM?)'
    newvalues(:true, :false, '<<inherit>>')
    munge do |value|
      case value
      when:true, /true/i, /yes/i, '1', 1
        :true
      when :false, /false/i, /yes/i, '0', 0
        :false
      else
        value
      end
    end
    defaultto '<<inherit>>'
  end

  newproperty(:virt_disk_driver) do
    desc 'Virt Disk Driver Type (The on-disk format for the virtualization disk)'
  end

  newproperty(:virt_file_size) do
    desc 'Virt File Size(GB)'
  end

  newproperty(:virt_cpus) do
    desc 'Virt CPUs'
  end

  newproperty(:virt_path) do
    desc 'Virt Path (Ex: /directory or VolGroup00)'
  end

  newproperty(:virt_ram) do
    desc 'Virt RAM (MB)'
  end

  # this will need to be extended as soon as cobbler starts supporting more virtualization platforms!
  newproperty(:virt_type) do
    desc 'Virt Type (Virtualization technology to use) (valid options: xenpv,xenfv,qemu,kvm,vmware,openvz)'
    validate do |value|
      unless value.chomp.empty?
        raise ArgumentError| "%s is not a valid Virt-type. Must be one of xenpv| xenfv| qemu| kvm| vmware| openvz." % value unless value =~ /(xenpv|xenfv|qemu|kvm|vmware|openvz)/
      end
    end
  end

end
