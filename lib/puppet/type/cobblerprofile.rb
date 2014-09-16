Puppet::Type.newtype(:cobblerprofile) do
@doc = "Manages the Cobbler profiles

A typical rule will look like this:

cobblerprofile {'CentOS-6.3-x86_64':
  ensure        => present,
  distro        => 'CentOS-6.3-x86_64',
}"
 
  desc 'The cobbler profile type'

  ensurable

  newparam(:name) do
    isnamevar
    desc 'The name of the profile'
  end

  newproperty(:distro) do
    desc 'Distribution this profile is based on'
  end
  autorequire(:cobblerdistro) do
    self[:distro]
  end

  newproperty(:parent) do
    desc 'Parent profile that this profile is based on'
  end
  autorequire(:cobblerprofile) do
    self[:parent]
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

  newproperty(:kickstart) do
    desc 'Kickstart file used by profile'
  end
  autorequire(:file) do
    self[:kickstart]
  end

  newproperty(:nameservers, :array_matching => :all) do
    desc 'List of nameservers for this profile'
    # http://projects.puppetlabs.com/issues/10237
    def insync?(is)
      return false unless is == should
      true
    end
  end

  newproperty(:search, :array_matching => :all) do
    desc 'List of nameserver search domains for this profile'
    # http://projects.puppetlabs.com/issues/10237
    def insync?(is)
      return false unless is == should
      true
    end
  end

  newproperty(:repos, :array_matching => :all) do
    desc "list of repositories added to profile"
    # http://projects.puppetlabs.com/issues/10237
    def insync?(is)
      return false unless is == should
      true
    end

  end

  autorequire(:cobblerrepo) do
    self[:repos]
  end


  newproperty(:comment) do
    desc 'Human readable description of this profile.'
  end

  newproperty(:virt_auto_boot) do
    desc 'Virt Auto Boot (Auto boot this VM?)'
    newvalues(:true, :false)
    munge do |value|
      case value
      when :true, /true/i, /yes/i, '1', 1
        :true
      when :false, /false/i, /yes/i, '0', 0, nil
        :false
      end
    end
    defaultto :true
  end

  newproperty(:virt_bridge) do
    desc 'Virt Bridge'
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
