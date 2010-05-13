pkg 'lighttpd webserver', :for => :ubuntu do
  installs { via :apt, 'lighttpd' }
  provides []
end

pkg 'php cgi', :for => :ubuntu  do
  installs { via :apt, 'php5-cgi' }
  provides []
end

dep 'php for lighttpd', :for => :linux do
  requires 'lighttpd webserver', 'php cgi'
  met? {
    File.exist? '/etc/lighttpd/conf-enabled/10-fastcgi.conf'   
  }

  meet {
   sudo '/usr/sbin/lighty-enable-mod fastcgi'
  }
end
