pkg 'php cgi', :for => :ubuntu  do
  installs { via :apt, 'php5-cgi' }
  provides []
end

dep 'php for lighttpd', :for => :linux do
  requires 'lighttpd webserver', 'fastcgi', 'php cgi'
end

dep 'php' do
  setup {
    requires "php for #{var(:webserver, :default => 'lighttpd', :message => 'Setup php for ')}" 
  }
end
