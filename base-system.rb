dep 'populated dev', :for => :linux do
    met? { shell 'test "$(ls -A /dev)"' }
    meet {
        in_dir '/dev' do
	    sudo 'MAKEDEV generic'
	end
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

dep 'configured fstab', :for => :linux do
    requires 'populated dev', 'existing fstab'

    target = '/etc/fstab'

    met? { 
	fstab = read_file target
	!fstab.empty? and fstab != '# UNCONFIGURED FSTAB FOR BASE SYSTEM'
    }
    meet {
	define_var :rootfs, :message => "/ (root) file system device node ?", :default => '/dev/sda1'
	define_var :swapfs, :message => "swap  file system device node ?",    :default => '/dev/sda2'
	define_var :bootfs, :message => "/boot file system device node ? (type \"#unused\" for no separate partition)", :default => '#unused'
	define_var :tmpfs,  :message => "/tmp  file system device node ? (type \"#unused\" for no separate partition)", :default => '#unused'
	define_var :varfs,  :message => "/var  file system device node ? (type \"#unused\" for no separate partition)", :default => '#unused'
	define_var :usrfs,  :message => "/usr  file system device node ? (type \"#unused\" for no separate partition)", :default => '#unused'
	define_var :homefs, :message => "/home file system device node ? (type \"#unused\" for no separate partition)", :default => '#unused'
    	render_erb 'base-system/fstab.erb', :to => target, :sudo => !File.writable?(File.dirname(target))
    }
end
