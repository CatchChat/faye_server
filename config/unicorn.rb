worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true
pid RAILS_ROOT + "/tmp/pids/unicorn.pid"
listen RAILS_ROOT + '/shared/tmp/sockets/unicorn.sock', :backlog => 2048
before_fork do |server, worker|

  old_pid = RAILS_ROOT + '/shared/tmp/pids/unicorn.pid'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
