pkg 'lighttpd webserver', :for => :ubuntu do
  installs { via :apt, 'lighttpd' }
  provides []
end

meta :lighttpd_module do
  accepts_list_for :module_name
  template {
    requires 'lighttpd webserver'
    met? {
      module_name.all? {|mod|
        shell "lighttpd-enable-mod none |grep \"^Already enabled modules:.*#{mod}\""
      }
    }
    meet {
      module_name.each {|mod|
        sudo "lighttpd-enable-mod #{mod}"
        log_ok "enabled #{mod}"
      }
      sudo('/etc/init.d/lighttpd restart')
    }
  }
end

lighttpd_module 'fastcgi' do
  module_name 'fastcgi'
end
