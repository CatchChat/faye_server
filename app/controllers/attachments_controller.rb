class AttachmentsController < ApiController
  skip_before_action :authenticate_user, only: :callback

  # GET /api/attachments/upload_token/:provider
  # params for qiniu: bucket, key
  # example:
  # http://localhost:3000/api/v4/attachments/upload_token/qiniu.json?bucket=mybucket&key=myobject.txt
  # params for upyun: bucket, file_path, file_length
  # example:
  # http://localhost:3000/api/v4/attachments/upload_token/upyun.json?bucket=mybucket&file_path=myobject.txt&file_length=23
  def upload_token
    raise Cdn::MissingParam, "missing params for upload token" unless @message = Message.find_by(id: params[:id].to_i)
    @provider = 'qiniu'
    @cdn = QiniuHelper.client
    @token = @cdn.get_upload_token key: SecureRandom.uuid

  rescue Cdn::MissingParam => e
    render json: {message: e.message}, status: :not_acceptable
  end

  def upload_fields
    @cdn = init_cdn
    url, policy, encoded_policy, signature = @cdn.get_upload_form_url_fields
    render json: {status: 'ok', url: url, policy: policy, encoded_policy: encoded_policy, signature: signature}
  rescue Cdn::MissingParam => e
    render json: {status: 'error', message: e.message}, status: :not_acceptable
  end

  # POST "/api/attachments/callback/:provider"
  # parms: provider, bucket, key
  # example
  # Started POST "/api/v4/attachments/callback/upyun" for 127.0.0.1 at
  # 2014-11-20 17:53:57 +0800
  # Processing by AttachmentsController#callback as HTML
  #   Parameters: {"code"=>"200", "url"=>"/abcd.jpg", "time"=>"1416477184",
  #   "ext-param"=>"", "sign"=>"d72be160641a0f91016ca66aab10c4c3",
  #   "message"=>"ok", "provider"=>"upyun"}
  #
  # Started POST "/api/v4/attachments/callback/qiniu" for 127.0.0.1
  # Processing by AttachmentsController#callback as HTML
  #   Parameters: {"key"=>"test-key", "bucket"=>"ruanwz-public",
  #                "message_id"=>"1", "provider"=>"qiniu"}
  def callback
    provider = params[:provider]
    raise Cdn::MissingParam, "provider is not supported" unless provider == 'qiniu'
    if provider == 'qiniu'
      # TODO: verify request come from qiniu
      _bucket = params[:bucket]
      key = params[:key]
      raise Cdn::MissingParam, "message not exist" unless @message = Message.find_by(id: params[:message_id].to_i)
      attachment = Attachment.find_or_create_by! storage: provider,  file: key
      @message.attachments << attachment
      @message.mark_as_unread
      @message.push_notification


      render json: {provider: 'qiniu', file: key, message_id: @message.id, attachment_id: attachment.id}
    end
    if provider == 'upyun'
      key = params[:url]
      _attachment = Attachment.find_or_create_by! storage: provider,  file: key
      render json: {provider: 'upyun', file: key}
    end
  rescue Cdn::MissingParam => e
    render json: {message: e.message}, status: :not_acceptable
  end

  def download_token
    puts params
  end

  private

  def init_cdn
    case params[:provider]
    when 'qiniu'
      QiniuHelper.client
    when 'upyun'
      init_upyun_cdn
    when 's3'
      init_s3_cdn
    end

  end

  def init_upyun_cdn
    username      = ENV["upyun_username"]
    password      = ENV["upyun_password"]
    init_hash     = {
                      username:     username,
                      password:     password,
                      bucket:       params[:bucket],
                      file_path:    params[:file_path],
                      file_length:  params[:file_length]
                    }
    upyun_client = UpyunCdn.new init_hash
    Cdn.new(upyun_client)

  end

  def init_s3_cdn
    # TODO implement s3

    aws_access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
    aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    aws_sqs_queue         = ENV["AWS_SQS_QUEUE"]

    init_hash    = { aws_access_key_id:     aws_access_key_id,
                     aws_secret_access_key: aws_secret_access_key,
                     sqs_queue_name:        aws_sqs_queue,
                     bucket:                params[:bucket],
                     key:                   params[:key]
                   }

    s3_client = S3Cdn.new init_hash
    Cdn.new(s3_client)
  end
end
