pkg 'lighttpd webserver', :for => :ubuntu do
  installs { via :apt, 'lighttpd' }
end

pkg 'php cgi', :for => :ubuntu  do
  installs { via :apt, 'php5-cgi' }
end

dep 'php for lighttpd', :for => :linux do
  requires 'lighttpd webserver', 'php cgi'
  met? {
    File.exist? '/etc/lighttpd/conf-available/10-fastcgi-php5.conf'   
  }

  meet {
    
  }
end
