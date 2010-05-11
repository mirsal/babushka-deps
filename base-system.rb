dep 'populated dev', :for => :linux do
    met? { shell 'test "$(ls -A /dev)"' }
    meet {
        in_dir '/dev' do
	    sudo 'MAKEDEV generic'
	end
    }
end
