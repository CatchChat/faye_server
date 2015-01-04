require 'aws-sdk-v1'
#require_relative '../../spec/services_helper'
#Rails.application.eager_load!

desc "Read S3 Notification"
task :read_s3_notification => :environment do
  # TODO: update Message record for attachment uploaded complete
  aws_access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
  aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]

  client_init_hash    = { aws_access_key_id: aws_access_key_id,
                      aws_secret_access_key: aws_secret_access_key,
                             sqs_queue_name: 's3-ruanwz-test-post',
                                     bucket: 'ruanwz-test'}

  cdn_init_hash    = { aws_access_key_id: aws_access_key_id,
                   aws_secret_access_key: aws_secret_access_key}

  s3_client = S3Cdn.new client_init_hash
  cdn       = Cdn.new(s3_client, cdn_init_hash)
  cdn.sqs_poll do |key|
    attachment = Attachment.find_by storage: 's3', file: key
    message = attachment.message
    return unless message
    message.mark_as_unread
    MessageNotificationJob.perform_async(message.id)

  end
end

