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

pkg 'mount' do
  cfg '/etc/fstab'
  setup {
    define_var :dhcp_network,
      :type => :ip_range,
      :default => '10.0.1.x',
      :message => "What network range would you like to serve DHCP on?"

    set :dhcp_subnet, L{ Babushka::IPRange.new(var(:dhcp_network)).subnet }
    set :dhcp_broadcast_ip, L{ Babushka::IPRange.new(var(:dhcp_network)).broadcast }

    define_var :dns_domain, :message => "The network's domain", :default => 'example.org'
    define_var :dns_server_ip, :message => "The DNS server itself", :default => L{ Babushka::IPRange.new(var(:dhcp_network)).first }
    define_var :dhcp_router_ip, :message => "Default gateway", :default => L{ var :dns_server_ip }
    define_var :dhcp_start_address, :message => "DHCP starting address", :default => L{ Babushka::IP.new(var(:dns_server_ip)).next }
    define_var :dhcp_end_address, :message => "DHCP ending address", :default => L{ Babushka::IPRange.new(var(:dhcp_network)).last.prev }
  }
end
