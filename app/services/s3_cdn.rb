require 'aws-sdk-v1'
require 'vanguard'
require 'virtus'

class S3Cdn
  include Virtus.model
  attribute :aws_access_key_id, String
  attribute :aws_secret_access_key, String
  attribute :bucket, String
  attribute :s3bucket, AWS::S3::Bucket
  attribute :key, String
  attribute :expires_in, Integer, default: 3600
  attribute :file_location, String
  attribute :region, String, default: ENV['AWS_REGION'] || 'cn-north-1'
  attribute :success_action_redirect, String
  attribute :acl, String
  attribute :sqs_queue_name, String
  def initialize(keys)
    super
  end

  def prepare(cdn)
    self.attributes = self.attributes.merge cdn.options

    s3client = AWS::S3::Client.new :signature_version => :v4
    self.s3bucket = AWS::S3::Bucket.new(bucket, :s3_client => s3client, :signature_version => :v4)
  end

  def get_download_url(args)
    self.attributes = self.attributes.merge args
    fail unless DOWNLOADVALIDATOR.call(self).valid?

    s3bucket.objects[key].url_for( :read, { :secure => true }).to_s

  end

  def get_upload_form_url_fields(args = {})
    self.attributes = self.attributes.merge args
    fail unless UPLOADVALIDATOR.call(self).valid?

    date = Time.now.strftime("%Y%m%dT%H%M%SZ")
    #format for expire_date: 2013-08-06T12:00:00.000Z
    expire_date = (Time.now + expires_in).strftime("%Y-%m-%dT%H:%M:%S.000Z")

    if region.match 'cn'
      url = "https://#{bucket}.s3.#{region}.amazonaws.com.cn/"
    else
      url = "https://#{bucket}.s3.amazonaws.com/"
    end
    conditions_list = Array.new.tap do |array|
      array << {"bucket" => bucket}
      array << {"key" => key}
      array << {'acl' => 'private'}
      array << {'success_action_redirect' => success_action_redirect} if success_action_redirect
      array << {"x-amz-credential"=> "#{aws_access_key_id}/#{date[0,8]}/#{region}/s3/aws4_request"}
      array << {"x-amz-algorithm"=> "AWS4-HMAC-SHA256"}
      array << {"x-amz-date"=> date }
    end

    policy = {
      "expiration" => expire_date,
      "conditions" => conditions_list
    }

    encoded_policy = Base64.encode64(policy.to_json).tr("\n","")
    signature = bin_to_hex(hmac(derive_key(date), encoded_policy))

    [url, policy, encoded_policy, signature]
  end

  def upload_file(args)
    url, policy, encoded_policy, signature = get_upload_form_url_fields(args)
    mime_type =  MIME::Types.type_for(file_location).first
    payload = Hash.new.tap do |hash|
      hash[:key]                     = fetch_policy(policy,"key")
      hash[:acl]                     = fetch_policy(policy, 'acl')
      hash[:success_action_redirect] = success_action_redirect if success_action_redirect
      hash[:"X-Amz-Algorithm"]       = fetch_policy(policy, 'x-amz-algorithm')
      hash[:"X-Amz-Signature"]       = signature
      hash[:"X-Amz-Date"]            = fetch_policy(policy,"x-amz-date")
      hash[:"X-Amz-Credential"]      = fetch_policy(policy, "x-amz-credential")
      hash[:"Policy"]                = encoded_policy
      hash[:file]                    = Faraday::UploadIO.new(file_location, mime_type.content_type)
    end

    conn = Faraday.new(url: url) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      #faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    resp = conn.post nil, payload do |req|
      req.headers['Content-Type'] =  'multipart/form-data'
    end
    resp.status
  end

  def sqs_poll
    sqs = AWS::SQS.new
    queue = sqs.queues.named(sqs_queue_name)

    queue.poll(wait_time_seconds: 10) do |poll_message|
      message = JSON.parse(poll_message.body)
      _keys = message.fetch("Records").map do |record|
        _post_obj_key = record.fetch("s3").fetch("object").fetch("key")
      end
      puts _keys

    end

  end

  def sqs_receive
    sqs = AWS::SQS.new
    queue = sqs.queues.named(sqs_queue_name)
    received_message = queue.receive_message(wait_time_seconds: 20)
    message = JSON.parse(received_message.body)
    message.fetch("Records").map do |record|
      _post_obj_key = record.fetch("s3").fetch("object").fetch("key")
    end
  end

  DOWNLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :key
  end

  UPLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :key
  end

  private

  def bin_to_hex(s)
    #s.each_byte.map { |b| b.to_s(16) }.join
    s.unpack('H*')[0]
  end
  def sha256_digest
    OpenSSL::Digest.new('sha256')
  end

  def hmac key, value
    OpenSSL::HMAC.digest(sha256_digest, key, value)
  end

  def hexhmac key, value
    OpenSSL::HMAC.hexdigest(sha256_digest, key, value)
  end

  def derive_key(date)
    fail unless date.is_a? String
    service_name  = 's3'
    k_secret      = aws_secret_access_key
    k_date        = hmac("AWS4" + k_secret, date[0,8])
    k_region      = hmac(k_date, region)
    k_service     = hmac(k_region, service_name)
    k_credentials = hmac(k_service, 'aws4_request')
  end

  def fetch_policy(policy,name)
    (policy["conditions"].find {|con|con.keys == [name]} ).values.first
  end
end
