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

lighttpd_vhost 'symfony lighttpd vhost' do
  domain var(:domain)
  config_file_template 'lighttpd/vhosts/symfony.conf.erb'
  priority 15
end

dep 'symfony vhost' do
  setup {
      requires 'php', "symfony #{var(:webserver)} vhost"
  }
end
