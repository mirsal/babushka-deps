dep 'symfony vhost' do
  setup {
      requires "symfony #{var(:webserver, :default => 'lighttpd')} vhost"
  }
end

dep 'symfony app' do
  setup {
      requires 'php', 'symfony vhost' 
  }
end
