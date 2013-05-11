#set :whenever_command, "bundle exec whenever"
require "bundler/capistrano"
#require "whenever/capistrano"

server "198.211.99.163", :web, :app, :db, primary: true

set :application, "poploda"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "ssh://sls@slsapp.com:1234/poploda/#{application}.git"
set :scm_username, "evenmatrix@gmail.com"
set :branch, "master"
set :git_enable_submodules, 1

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:paranoid] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/config/environments"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/environments/production.example.rb"), "#{shared_path}/config/environments/production.rb"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/environments/production.rb #{release_path}/config/environments/production.rb"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
  after "deploy", "deploy:migrate"


  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end