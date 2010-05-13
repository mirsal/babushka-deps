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

dep 'cache dir exists' do
  requires 'cloned symfony project repo'
  met? {
    in_dir var(:document_root) do
      (var(:document_root) / 'cache').exist?
    end
  }
  meet {
    in_dir var(:document_root) do
      sudo "mkdir -p #{var(:document_root) / 'cache'}"
    end
  }
end

def symfony_task task, args = nil
  in_dir var(:document_root) do
    sudo "php symfony #{task} #{args}"
  end
end

dep 'permissions set' do
  requires 'cache dir exists'
  met? {
    in_dir var(:document_root) do
      File.stat('cache').mode[777].nil? && log('cache perms ok')
    end
  }
  meet {
      symfony_task 'project:permissions'
  }
end

dep 'symfony app' do
  setup {
    requires 'php', 'symfony vhost', 'cloned symfony project repo', 'permissions set' 
  }
end
