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

    s3client = AWS::S3::Client.new
    self.s3bucket = AWS::S3::Bucket.new('rails-test', :s3_client => s3client, :signature_version => :v4)

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
    self.attributes = self.attributes.merge args

    url, fields = get_upload_form_url_fields key: key, signature_version: :v4

    conn = Faraday.new(url: url) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    mime_type =  MIME::Types.type_for(file_location).first

    fields = fields.inject({}) do |hash,(k,v)|
      hash[k.to_sym] = v
      hash
    end
    payload = {
      :key => fields[:key],
      :"X-Amz-Algorithm" => "AWS4-HMAC-SHA256",
      :"X-Amz-Signature" => fields[:signature],
      #:"X-Amz-Date" => Time.now.strftime("%Y%m%dT%H%M%SZ"),
      :"X-Amz-Date" => Time.now.strftime("%Y%m%dT000000Z"),
      :"X-Amz-Credential" => "AKIAOGBVMZAU5EZPGPIQ/20141021/cn-north-1/s3/aws4_request",
      :"Policy" => fields[:policy],
      file: Faraday::UploadIO.new(file_location, mime_type.content_type)
    }
    resp = conn.post nil, payload do |req|
      req.headers['Content-Type'] =  'multipart/form-data'
    end
    binding.pry
    resp.status
  end
  DOWNLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :key
  end

  UPLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :key
  end

  private

end
