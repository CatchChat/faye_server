module S3Helper
  def self.client
    aws_access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
    aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    aws_sqs_queue         = ENV["AWS_SQS_QUEUE"]
    aws_bucket            = ENV["AWS_BUCKET"]

    init_hash    = { aws_access_key_id:     aws_access_key_id,
                     aws_secret_access_key: aws_secret_access_key,
                     sqs_queue_name:        aws_sqs_queue,
                     bucket:                aws_bucket
                     # key:                   params[:key]
                   }

    s3_client = S3Cdn.new init_hash
    Cdn.new(s3_client)
  end
end
