pkg 'php cgi', :for => :linux  do
  installs { via :apt, 'php5-cgi' }
  provides []
end

pkg 'php cli', :for => :linux do
  installs { via :apt, 'php5-cli' }
  provides []
end

dep 'php for lighttpd', :for => :linux do
  requires 'lighttpd webserver', 'fastcgi', 'php cgi'
end

dep 'php' do
  setup {
    requires 'php cli', "php for #{var(:webserver, :default => 'lighttpd', :message => 'Setup php for ')}" 
  }
end
