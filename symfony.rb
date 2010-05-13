dep 'symfony vhost' do
  setup {
      requires "symfony #{var(:webserver, :default => 'lighttpd')} vhost"
  }
end

dep 'symfony app' do
  setup {
    requires 'php', 'symfony vhost' 
  }

  met? {
    (var(:document_root) / 'symfony').exist?
  }

  meet {
    in_dir var(:document_root) do
      sudo "git clone #{var(:project_git_repository)}"
    end
  }
end
