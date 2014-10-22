require 'aws-sdk-v1'
require 'vanguard'
require 'virtus'

class S3Cdn
  include Virtus
  attribute :aws_access_key_id, String
  attribute :aws_secret_access_key, String
  attribute :bucket, String
  attribute :s3bucket, AWS::S3::Bucket
  attribute :key, String
  attribute :expires_in, String
  attribute :file_location, String
  def initialize(keys)
    super
  end

  def prepare(cdn)
    self.attributes = self.attributes.merge cdn.options

    @s3client = AWS::S3::Client.new :signature_version => :v4
    self.s3bucket = AWS::S3::Bucket.new('rails-test', :s3_client => @s3client, :signature_version => :v4)

  end

  def get_upload_form_url_fields(args = {})
    self.attributes = self.attributes.merge args
    fail unless UPLOADVALIDATOR.call(self).valid?

    form = s3bucket.presigned_post(key: key)
    [form.url.to_s, form.fields]
  end


  def get_download_url(args)
    self.attributes = self.attributes.merge args
    fail unless DOWNLOADVALIDATOR.call(self).valid?

    s3bucket.objects[key].url_for( :read, { :secure => true }).to_s

  end


  def upload_file(args)
    @date = Time.now.strftime("%Y%m%dT%H%M%SZ")
    #format for expire_date: 2013-08-06T12:00:00.000Z
    @expire_date = (Time.now+3600).strftime("%Y-%m-%dT%H:%M:%S.000Z")
    self.attributes = self.attributes.merge args

    url, _fields = get_upload_form_url_fields key: key, signature_version: :v4

    conn = Faraday.new(url: url) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      #faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    mime_type =  MIME::Types.type_for(file_location).first


    policy = { "expiration" => @expire_date,
      "conditions" => [
        {"bucket" => "rails-test"},
        {"key" => "iwebcam.jpg"},
        {"x-amz-credential"=> "AKIAOGBVMZAU5EZPGPIQ/#{@date[0,8]}/cn-north-1/s3/aws4_request"},
        {"x-amz-algorithm"=> "AWS4-HMAC-SHA256"},
        {"x-amz-date"=> @date }
      ]
    }
    policy = Base64.encode64(policy.to_json).tr("\n","")

    #AWS::Core::Signers::Version4.new @s3client.credential_provider
    payload = {
      :key => 'iwebcam.jpg',
      :"X-Amz-Algorithm" => "AWS4-HMAC-SHA256",
      :"X-Amz-Signature" => bin_to_hex(hmac(derive_key, policy)),
      #:"X-Amz-Date" => Time.now.strftime("%Y%m%dT%H%M%SZ"),
      :"X-Amz-Date" => @date,
      :"X-Amz-Credential" => "AKIAOGBVMZAU5EZPGPIQ/#{@date[0,8]}/cn-north-1/s3/aws4_request",
      :"Policy" => policy,
      file: Faraday::UploadIO.new(file_location, mime_type.content_type)
    }
    resp = conn.post nil, payload do |req|
      req.headers['Content-Type'] =  'multipart/form-data'
    end
    resp.status
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

  def derive_key(datetime=nil)
    region = 'cn-north-1'
    service_name = 's3'
    k_secret = aws_secret_access_key
    k_date = hmac("AWS4" + k_secret, @date[0,8])
    k_region = hmac(k_date, region)
    k_service = hmac(k_region, service_name)
    k_credentials = hmac(k_service, 'aws4_request')
  end
end
