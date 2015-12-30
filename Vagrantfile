# -*- mode: ruby -*-
# vi: set ft=ruby :

# fail if plugin is not installed
unless Vagrant.has_plugin?('vagrant-hostmanager')
    error_str = <<-EOF
    Vagrant Plugin vagrant-hostmanager missing!
    Install the plugin with:
    $ vagrant plugin install vagrant-hostmanager
    EOF
    raise Vagrant::Errors::VagrantError.new, error_str
end
unless Vagrant.has_plugin?('vagrant-triggers')
    error_str = <<-EOF
    Vagrant Plugin vagrant-triggers missing!
    Install the plugin with:
    $ vagrant plugin install vagrant-triggers
    EOF
    raise Vagrant::Errors::VagrantError.new, error_str
end

require 'yaml'

hosts = YAML.load_file('hosts.yaml')

#puts hosts.inspect

domain = hosts["domain"] ||= 'local'
boxes = hosts["boxes"]

Vagrant.configure(2) do |config|
    # enable and configure hostmanager
    config.hostmanager.enabled = true
    config.hostmanager.include_offline = true
    # Workaround to make this happen with DHCP,
    # s. https://github.com/smdahlen/vagrant-hostmanager/issues/86
    config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
        if vm.id
            `VBoxManage guestproperty get #{vm.id} '/VirtualBox/GuestInfo/Net/1/V4/IP'`.split()[1]
        end
    end
    boxes.each do |host|
        config.vm.define host["name"] do |srv|
            srv.vm.box = host["box"]
            if host["box_url"]
                srv.vm.box_url = host["box_url"]
            end
            # use cachier if it's installed
            if Vagrant.has_plugin?('vagrant-cachier')
                srv.cache.scope = :box
            end
            srv.vm.hostname = host["hostname"] + '.' + domain
            srv.vm.network 'private_network', type: 'dhcp'
            srv.vm.provider :virtualbox do |vb|
                vb.memory = host["memory"] ||= 1024
                vb.cpus   = host["cpus"] ||= 1
            end
            provision = host["provision"]
            if provision
                provision.each do |script|
                    if script["run"] == 'always'
                        srv.vm.provision :shell,
                            :path => script["name"], :run => 'always'
                    else
                        srv.vm.provision :shell,
                            :path => script["name"]
                    end
                end
            end
            triggers = host["triggers"]
            if triggers
                triggers.each do |t|
                    config.trigger.after :up do
                        run_remote t 
                    end
                end
            end
        end
    end
end
