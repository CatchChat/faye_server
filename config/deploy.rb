# config valid only for Capistrano 3.2.1
lock '3.2.1'

set :application, 'catchchat_server'
set :repo_url, 'git@github.com:CatchChat/catchchat_server.git'

# Default branch is :master
# Uncomment the following line to have Capistrano ask which branch to deploy.
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Replace the sample value with the name of your application here:
set :deploy_to, '/u/apps/catchchat_server_staging'

# Use agent forwarding for SSH so you can deploy with the SSH key on your workstation.
set :ssh_options, {
  forward_agent: true
}

# Default value for :pty is false
set :pty, true
set :unicorn_config_path, "#{current_path}/config/unicorn.rb"
set :unicorn_rack_env, 'staging'
set :bundle_bins, fetch(:bundle_bins, []).push("unicorn")

set :linked_files, %w{config/database.yml .rbenv-vars .ruby-version config/secrets.yml config/settings/production.yml config/settings/staging.yml config/unicorn.rb}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :default_env, { path: "/opt/rbenv/shims:$PATH" }

set :keep_releases, 5

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end

  after 'deploy:publishing', 'restart'
end
