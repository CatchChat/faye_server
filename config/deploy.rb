require 'capistrano/sidekiq'
require 'capistrano/sidekiq/monit'
require 'capistrano/slackify'

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
set :pty, false
set :unicorn_config_path, "#{current_path}/config/unicorn.rb"
set :unicorn_rack_env, 'staging'
set :bundle_bins, fetch(:bundle_bins, []).push("unicorn")

set :linked_files, %w{config/database.yml .rbenv-vars .ruby-version config/secrets.yml config/settings.local.yml config/settings/production.yml config/unicorn.rb config/sidekiq.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/javascripts public/stylesheets public/assets}

set :default_env, { path: "/opt/rbenv/shims:$PATH" }

set :keep_releases, 5

### Sidekiq
set :sidekiq_config, -> { File.join(shared_path, 'config', 'sidekiq.yml') }
set :sidekiq_default_hooks, -> { true }
set :sidekiq_pid, -> { File.join(shared_path, 'tmp', 'pids', 'sidekiq.pid') }
set :sidekiq_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
set :sidekiq_log, -> { File.join(shared_path, 'log', 'sidekiq.log') }
set :sidekiq_timeout, -> { 10 }
set :sidekiq_role, -> { :app }
set :sidekiq_processes, -> { 1 }
# Rbenv and RVM integration
set :rbenv_map_bins, fetch(:rbenv_map_bins).to_a.concat(%w(sidekiq sidekiqctl))
set :rvm_map_bins, fetch(:rvm_map_bins).to_a.concat(%w(sidekiq sidekiqctl))
set :sidekiq_monit_conf_dir, -> { '/etc/monit/conf.d' }
set :monit_bin, -> { '/usr/bin/monit' }
set :sidekiq_monit_default_hooks, -> { true }

### slack
set :slack_url, 'https://hooks.slack.com/services/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'
set :slack_channel, '#server-side'
set :slack_username, 'Deploybot'
set :slack_emoji, ':trollface:'
set :slack_user, 'Capistrano'
set :slack_text, -> {
  elapsed = Integer(fetch(:time_finished) - fetch(:time_started))
  "Revision #{fetch(:current_revision, fetch(:branch))} of " \
  "#{fetch(:application)} deployed to #{fetch(:stage)} by #{fetch(:slack_user)} " \
  "in #{elapsed} seconds."
}
set :slack_deploy_starting_text, -> {
  "#{fetch(:stage)} deploy starting with revision/branch #{fetch(:current_revision, fetch(:branch))} for #{fetch(:application)}"
}
set :slack_deploy_failed_text, -> {
  "#{fetch(:stage)} deploy of #{fetch(:application)} with revision/branch #{fetch(:current_revision, fetch(:branch))} failed"
}
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end

  after 'deploy:publishing', 'restart'
end

