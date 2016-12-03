# config valid only for current version of Capistrano
lock '3.6.1'

set :application, "burgerbot"
#set :local_repository, "."
#set :deploy_via, :copy
set :tmp_dir, "/home/burgerbot/tmp"
set :repo_url, "git@github.com:yourname/yourrepo.git"
set :pty, true

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/burgerbot"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

namespace :app do
  task :compile do
    on roles(:all) do
      execute "cd #{current_path} && ./setup"
    end
  end

  namespace :symlink do
    task :shared do
      on roles(:all) do
        execute "ln -nfs #{shared_path}/config/prod.secret.exs #{current_path}/apps/web_api/config/prod.secret.exs"
        execute "ln -nfs #{shared_path}/_build/ #{current_path}/_build"
      end
    end
  end

  task :start do
    on roles(:all) do
      execute :sudo, "/usr/sbin/service #{fetch(:application)} start"
    end
  end

  task :stop do
    on roles(:all) do
      execute :sudo, "/usr/sbin/service #{fetch(:application)} stop"
    end
  end

  task :restart do
    on roles(:all) do
      execute :sudo, "/usr/sbin/service #{fetch(:application)} stop"
      execute :sudo, "/usr/sbin/service #{fetch(:application)} start"
    end
  end
end

after "deploy:published", "app:symlink:shared"
after "deploy:published", "app:compile"
after "deploy:published", "app:restart"
