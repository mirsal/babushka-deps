pkg 'mysql server', :for => :ubuntu do 
  installs {
    via :apt, %w[mysql-server]
  }
  provides 'mysql'
end
