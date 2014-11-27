require 'globalid'
require 'active_support'
require "active_job/base"

# TODO: the setting could change in rails 4.2
ActiveJob::Base.queue_adapter = :sidekiq
# config.active_job.queue_adapter = :sidekiq
# config.active_job.queue_name_prefix = Rails.env

