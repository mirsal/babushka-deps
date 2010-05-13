pkg 'mysql software', :for => :ubuntu do 
  installs {
    via :apt, %w[mysql-server libmysqlclient-dev]
  }
  provides 'mysql'
end
