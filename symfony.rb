dep 'symfony vhost' do
  setup {
      requires "symfony #{var(:webserver, :default => 'lighttpd')} vhost"
  }
end

dep 'cloned symfony project repo' do
  met? {
    (var(:document_root) / 'symfony').exist?
  }

  meet {
    in_dir var(:document_root) do
      sudo "git clone #{var(:project_git_repository)} ."
    end
  }
end

def symfony_task task, args
  in_dir var(:document_root) do
    sudo "php symfony #{task} #{args}"
  end
end

dep 'permissions set' do
  requires 'cloned symfony project repo'
  met? {
    in_dir var(:document_root) do
      File.stat('cache').mode['777'].nil? && log 'cache perms ok'
    end
  }
end

dep 'symfony app' do
  setup {
    requires 'php', 'symfony vhost', 'cloned symfony project repo', 'permissions set' 
  }
end
