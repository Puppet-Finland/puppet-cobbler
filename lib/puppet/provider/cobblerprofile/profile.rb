require 'xmlrpc/client'

Puppet::Type.type(:cobblerprofile).provide(:profile) do
  desc 'Support for managing the Cobbler profiles'

  commands :cobbler => '/usr/bin/cobbler'

  mk_resource_methods

  def self.instances
    keys = []
    # connect to cobbler server on localhost
    cobblerserver = XMLRPC::Client.new2('http://127.0.0.1/cobbler_api')
    # make the query (get all systems)
    xmlrpcresult = cobblerserver.call('get_profiles')

    # get properties of current system to @property_hash
    xmlrpcresult.each do |member|
      keys << new(
        :name             => member['name'],
        :ensure           => :present,
        :distro           => member['distro'],
        :parent           => member['parent'],
        :nameservers      => member['name_servers'],
        :repos            => member['repos'],
        :kickstart        => member['kickstart'],
        :comment          => member['comment'],
        :virt_auto_boot   => member['virt_auto_boot'].to_s,
        :virt_bridge      => member['virt_bridge'],
        :virt_disk_driver => member['virt_disk_driver'],
        :virt_file_size   => member['virt_file_size'],
        :virt_cpus        => member['virt_cpus'],
        :virt_path        => member['virt_path'],
        :virt_ram         => member['virt_ram'],
        :virt_type        => member['virt_type'],
      )
    end
    keys
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

    # sets distribution (distro)
    def distro=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--distro=' + value)
      @property_hash[:distro]=(value)
    end

    # sets parent profile
    def parent=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--parent=' + value)
      @property_hash[:parent]=(value)
    end

    # sets kickstart
    def kickstart=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--kickstart=' + value)
      @property_hash[:kickstart]=(value)
    end

    # sets nameservers
    def nameservers=(value)
      # create cobblerargs variable
      cobblerargs='profile edit --name=' + @resource[:name]
      # turn string into array
      cobblerargs = cobblerargs.split(' ')
      # set up nameserver argument 
      cobblerargs << ('--name-servers=' + value * ' ')
      # finally set value
      cobbler(cobblerargs)
      @property_hash[:nameservers]=(value)
    end

    # sets repos
    def repos=(value)
      # create cobblerargs variable
      cobblerargs='profile edit --name=' + @resource[:name]
      # turn string into array
      cobblerargs = cobblerargs.split(' ')
      # set up nameserver argument 
      cobblerargs << ('--repos=' + value * ' ')
      # finally set value
      cobbler(cobblerargs)
      @property_hash[:repos]=(value)
    end

    # sets comment
    def comment=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--comment=' + value)
      @property_hash[:comment]=(value)
    end

    # sets virt-auto-boot
    def virt_auto_boot=(value)
      tmparg='--virt-auto-boot=' + if value.to_s =~ /false/i then '0' else  '1' end
      cobbler('profile', 'edit', '--name=' + @resource[:name], tmparg)
      @property_hash[:virt_auto_boot]=(value)
    end

    # sets virt-bridge
    def virt_bridge=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--virt-bridge=' + value)
      @property_hash[:virt_bridge]=(value)
    end

    # sets virt-disk-driver
    def virt_disk_driver=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--virt-disk-driver=' + value)
      @property_hash[:virt_disk_driver]=(value)
    end

    # sets virt-file-size
    def virt_file_size=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--virt-file-size=' + value.to_s)
      @property_hash[:virt_file_size]=(value.to_s)
    end

    # sets virt-cpus
    def virt_cpus=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--virt-cpus=' + value.to_s)
      @property_hash[:virt_cpus]=(value.to_s)
    end

    # sets virt-path
    def virt_path=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--virt-path=' + value)
      @property_hash[:virt_path]=(value)
    end

    # sets virt-ram
    def virt_ram=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--virt-ram=' + value.to_s)
      @property_hash[:virt_ram]=(value.to_s)
    end

    # sets virt-type
    def virt_type=(value)
      cobbler('profile', 'edit', '--name=' + @resource[:name], '--virt-type=' + value)
      @property_hash[:virt_type]=(value)
    end


    def create
      # check profile name
      raise ArgumentError, 'you must specify "distro" or "parent" for profile' if @resource[:distro].nil? and @resource[:parent].nil? 

      # create cobblerargs variable
      cobblerargs  = 'profile add --name=' + @resource[:name] 
      cobblerargs += ' --distro=' + @resource[:distro] unless @resource[:distro].nil?
      cobblerargs += ' --parent=' + @resource[:parent] unless @resource[:parent].nil?
      
      # turn string into array
      cobblerargs = cobblerargs.split(' ')

      # run cobbler commands
      cobbler(cobblerargs)

      # add kickstart, nameservers & repos (distro and/or parent are needed at creation time)
      # - check if property is defined, if not inheritance is probability (from parent)
      self.kickstart        = @resource.should(:kickstart)        unless @resource[:kickstart].nil?        or self.kickstart        == @resource.should(:kickstart)
      self.nameservers      = @resource.should(:nameservers)      unless @resource[:nameservers].nil?      or self.nameservers      == @resource.should(:nameservers)
      self.repos            = @resource.should(:repos)            unless @resource[:repos].nil?            or self.repos            == @resource.should(:repos)
      self.comment          = @resource.should(:comment)          unless @resource[:comment].nil?          or self.comment          == @resource.should(:comment)
      self.virt_auto_boot   = @resource.should(:virt_auto_boot)   unless @resource[:virt_auto_boot].nil?   or self.virt_auto_boot   == @resource.should(:virt_auto_boot)
      self.virt_bridge      = @resource.should(:virt_bridge)      unless @resource[:virt_bridge].nil?      or self.virt_bridge      == @resource.should(:virt_bridge)
      self.virt_disk_driver = @resource.should(:virt_disk_driver) unless @resource[:virt_disk_driver].nil? or self.virt_disk_driver == @resource.should(:virt_disk_driver)
      self.virt_file_size   = @resource.should(:virt_file_size)   unless @resource[:virt_file_size].nil?   or self.virt_file_size   == @resource.should(:virt_file_size)
      self.virt_cpus        = @resource.should(:virt_cpus)        unless @resource[:virt_cpus].nil?        or self.virt_cpus        == @resource.should(:virt_cpus)
      self.virt_ram         = @resource.should(:virt_ram)         unless @resource[:virt_ram].nil?         or self.virt_ram         == @resource.should(:virt_ram)
      self.virt_type        = @resource.should(:virt_type)        unless @resource[:virt_type].nil?        or self.virt_type        == @resource.should(:virt_type)

      # final sync
      cobbler('sync')
      @property_hash[:ensure] = :present
    end

    def destroy
      # remove repository from cobbler
      cobbler('profile','remove','--name=' + @resource[:name])
      cobbler('sync')
      @property_hash[:ensure] = :absent
    end

    def exists?
      @property_hash[:ensure] == :present
    end
end
