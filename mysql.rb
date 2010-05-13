pkg 'mysql software', :for => :ubuntu do 
  installs {
    via :apt, %w[mysql-server libmysqlclient16-dev]
  }
  provides 'mysql'
end
