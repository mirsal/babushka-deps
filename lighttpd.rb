pkg 'lighttpd webserver', :for => :ubuntu do
  installs { via :apt, 'lighttpd' }
  provides []
end

def lighttpd_module_enabled? mod
  return shell "lighttpd-enable-mod none |grep \"^Already enabled modules:.* #{mod}\""
end

def enable_lighttpd_module mod
  sudo "lighttpd-enable-mod #{mod}"
  log_ok "enabled #{mod}"
end

def restart_lighttpd!
      sudo('/etc/init.d/lighttpd restart')
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
      restart_lighttpd!
    }
  }
end

lighttpd_module 'fastcgi' do
  module_name 'fastcgi'
end

meta :lighttpd_vhost do
  accepts_list_for :config_file_template
  accepts_list_for :priority

  template {

    requires 'lighttpd webserver'
    helper(:lighttpd_vhost_conf_for) {|priority, domain| "/etc/lighttpd/conf-available/#{priority}-#{domain}.conf"}

    met? {
      define_var :domain, { :message => 'Symfony vhost domain' }

      domain = var(:domain)
      lighttpd_module_enabled? domain
    }
    meet {
      define_var :document_root, { :message => 'Symfony project root', :default => L{"/opt/#{var(:domain)}"} }
      domain = var(:domain)

      document_root = var(:document_root)
      sudo "mkdir -p #{document_root}"
      render_erb config_file_template, :to => lighttpd_vhost_conf_for(priority, domain), :sudo => true
      log "installed vhost for #{domain}"
      enable_lighttpd_module domain
      log "enabled vhost for #{domain}"
      restart_lighttpd!
    }
  }
end

lighttpd_vhost 'symfony lighttpd vhost' do
  config_file_template 'lighttpd/vhosts/symfony.conf.erb'
  priority 15
end
