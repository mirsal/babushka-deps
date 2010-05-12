dep 'populated dev', :for => :linux do
    met? { shell 'test "$(ls -A /dev)"' }
    meet {
        in_dir '/dev' do
	    sudo 'MAKEDEV generic'
	end
    }
end

dep 'mounted proc', :for => :linux do
    met? { shell 'test "$(ls -A /proc)"' }
    meet {
	sudo 'mount -t proc none /proc'
    }
end

dep 'existing fstab', :for => :linux do
    met? {
	File.exist? '/etc/fstab'
    }
    meet {
	sudo 'touch /etc/fstab'
    }
end

dep 'kernel image', :for => :ubuntu do
    met? { true }
end

dep 'bootloader', :for => :ubuntu do
    met? { true }
end

dep 'bootable system', :for => :linux do
    requires 'configured fstab', 'kernel image', 'bootloader'
end

dep 'configured fstab', :for => :linux do
    requires 'populated dev', 'mounted proc', 'existing fstab'

    target = '/etc/fstab'

    met? { 
	fstab = read_file target
	!fstab.empty? and fstab != '# UNCONFIGURED FSTAB FOR BASE SYSTEM'
    }
    meet {
	define_var :rootfs, :message => "/ (root) file system device node ?", :default => '/dev/sda1'
	define_var :swapfs, :message => "swap  file system device node ?",    :default => '/dev/sda2'
	define_var :bootfs, :message => "/boot file system device node ? (type \"#unused\" for no separate boot partition)", :default => '#unused'
	define_var :tmpfs,  :message => "/tmp  file system device node ? (type \"#unused\" for no separate temp partition)", :default => '#unused'
	define_var :varfs,  :message => "/var  file system device node ? (type \"#unused\" for no separate var  partition)", :default => '#unused'
	define_var :usrfs,  :message => "/usr  file system device node ? (type \"#unused\" for no separate usr  partition)", :default => '#unused'
	define_var :homefs, :message => "/home file system device node ? (type \"#unused\" for no separate home partition)", :default => '#unused'
    	render_erb 'base-system/fstab.erb', :to => target, :sudo => !File.writable?(File.dirname(target))
    }
end

dep 'existing hosts', :for => :linux do

    target = '/etc/hosts'

    met? {
	File.exist? target
    }
    meet {
	render_erb 'base-system/hosts.erb', :to => target, :sudo => !File.writable?(File.dirname(target))
    }
end

def security_source_for_system
    {
      :debian => 'http://security.debian.org/debian',
      :ubuntu => 'http://security.ubuntu.com/ubuntu'
    } [Babushka::Base.host.flavour]
end

meta :security_apt_source do
  accepts_list_for :source_name
  template {
    met? {
      source_name.all? {|name|
        grep(/^deb .* #{Babushka::Base.host.name}-security (\w+ )*#{Regexp.escape(name.to_s)}/, '/etc/apt/sources.list')
      }
    }
    meet {
      source_name.each {|name|
        append_to_file "deb #{security_source_for_system} #{Babushka::Base.host.name}-security #{name}", '/etc/apt/sources.list', :sudo => true
      }
    }
    after { Babushka::AptHelper.update_pkg_lists }
  }
end

security_apt_source 'main security apt source', :for => :ubuntu  do
    source_name 'main'
end

meta :tasksel do
    accepts_list_for :install_task
    template {
	met? {
            install_task.all? { |task|
                shell "tasksel --list-tasks | grep \"^i #{task}\""
            }
        }
        meet {
            install_task.each { |task|
                sudo "tasksel install #{task}"
            }
        }
    }
end

tasksel 'server install', :for => :ubuntu do
    requires 'existing hosts', 'hostname', 'configured fstab', 'main security apt source'
    install_task 'server'
end
