dep 'populated dev', :for => :linux do
    met? { shell 'test "$(ls -A /dev)"' }
    meet {
        in_dir '/dev' do
	    sudo 'MAKEDEV generic'
	end
    }
end

dep 'configured fstab', :for => :linux do
    requires 'populated dev'
    met? { 
	fstab = read_file '/etc/fstab'
	fstab and fstab != '# UNCONFIGURED FSTAB FOR BASE SYSTEM'
    }
    meet {}
end
