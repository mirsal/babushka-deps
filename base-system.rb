dep 'populated dev', :for => :linux do
  requires 'mounted proc'
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

pkg 'kernel image', :for => :ubuntu do
  met? {
    shell "ls --file-type /boot|grep -e \"[^/]$\""
  }
  installs {
    via :apt, 'linux-server'
  }
  provides []
end

pkg 'bootloader', :for => :ubuntu do
  installs {
    via :apt, 'grub'
  }
  provides []
end

dep 'bootable system', :for => :linux do
  requires 'configured fstab', 'kernel image', 'bootloader'
end

dep 'configured fstab', :for => :linux do
  requires 'populated dev', 'mounted proc'

  target = '/etc/fstab'

  met? { 
    fstab = read_file target
    !fstab.empty? and fstab['# UNCONFIGURED FSTAB FOR BASE SYSTEM'].nil?
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

  met? { target.p.exists? }
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

security_apt_source 'main security apt source', :for => :ubuntu do
  source_name 'main'
end

meta :tasksel do
  accepts_list_for :install_task
  template {
    met? {
      install_task.all? {|task|
        shell "tasksel --list-tasks | grep \"^i #{task}\""
      }
    }
    meet {
      install_task.each {|task|
        sudo "tasksel install #{task}"
      }
    }
  }
end

tasksel 'server install', :for => :ubuntu do
    requires 'existing hosts', 'hostname', 'bootable system', 'main security apt source'
    install_task 'server'
end
