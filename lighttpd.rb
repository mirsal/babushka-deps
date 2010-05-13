pkg 'lighttpd webserver', :for => :ubuntu do
  installs { via :apt, 'lighttpd' }
  provides []
end

def lighttpd_module_enabled? mod
  return shell "lighttpd-enable-mod none |grep \"^Already enabled modules:.*#{mod}\""
end

def enable_lighttpd_module mod
  sudo "lighttpd-enable-mod #{mod}"
  log_ok "enabled #{mod}"
end

meta :lighttpd_module do
  accepts_list_for :module_name
  template {
    requires 'lighttpd webserver'
    met? {
      module_name.all? {|mod|
        lighttpd_module_enabled? mod
      }
    }
    meet {
      module_name.each {|mod|
        enable_lighttpd_module mod
      }
      sudo('/etc/init.d/lighttpd restart')
    }
  }
end

lighttpd_module 'fastcgi' do
  module_name 'fastcgi'
end

meta :lighttpd_vhost do
  accepts_list_for :domain
  accepts_list_for :config_file_template
  accepts_list_for :priority

  template {

    helper(:lighttpd_vhost_conf_for) {|priority, domain| "/etc/lighttpd/conf-available/#{priority}-#{domain}.conf"}

    met? {
      domain.all? {|domain| lighttpd_module_enabled? domain}
    }
    meet {
      domain.each_with_index {|index, domain|
        render_erb config_file_template[index], :to => lighttpd_vhost_conf_for(priority[index], domain), :sudo => true
        log_ok "installed vhost for #{domain}"
        enable_lighttpd_module domain
        log_ok "enabled vhost for #{domain}"
      }
      sudo('/etc/init.d/lighttpd restart')
    }
  }
end

lighttpd_vhost 'test domain' do
  domain var(:domain)
  config_file_template 'lighttpd/vhosts/testdom.conf.erb'
  priority 15
end
