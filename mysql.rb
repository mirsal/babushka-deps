pkg 'mysql software', :for => :lucid do 
  installs {
    via :apt, %w[mysql-server libmysqlclient16-dev]
  }
  provides 'mysql'
end
