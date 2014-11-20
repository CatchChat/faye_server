class AttachmentsController < ApiController
  skip_before_action :authenticate_user

  # GET /api/attachments/upload_token/:provider
  # params for qiniu: bucket, key
  # example:
  # http://localhost:3000/api/v4/attachments/upload_token/qiniu.json?bucket=mybucket&key=myobject.txt
  # params for upyun: bucket, file_path, file_length
  # example:
  # http://localhost:3000/api/v4/attachments/upload_token/upyun.json?bucket=mybucket&file_path=myobject.txt&file_length=23
  def upload_token
    @cdn = init_cdn
    @token = @cdn.get_upload_token
  rescue Cdn::MissingParam => e
    render json: {status: 'error', message: e.message}, status: :not_acceptable
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
  # Started POST "/api/v4/attachments/callback/qiniu" for 127.0.0.1 at
  # 2014-11-20 17:58:38 +0800
  # Processing by AttachmentsController#callback as HTML
  #   Parameters: {"key"=>"test-key", "bucket"=>"ruanwz-public",
  #   "provider"=>"qiniu"}
  #
  def callback
    provider = params[:provider]
    if provider == 'qiniu'
      # TODO: verify request come from qiniu
      _bucket = params[:bucket]
      key = params[:key]
      _attachment = Attachment.find_or_create_by! storage: provider,  file: key
      render json: {status: 'ok', provider: 'qiniu', file: key}
    end
    if provider == 'upyun'
      key = params[:url]
      _attachment = Attachment.find_or_create_by! storage: provider,  file: key
      render json: {status: 'ok', provider: 'upyun', file: key}
    end
  rescue Cdn::MissingParam => e
    render json: {status: 'error', message: e.message}, status: :not_acceptable
  end

  def download_token
    puts params
  end

  private

  def init_cdn
    case params[:provider]
    when 'qiniu'
      init_qiniu_cdn
    when 'upyun'
      init_upyun_cdn
    when 's3'
      init_s3_cdn
    end

  end

  def init_qiniu_cdn
    access_key    = ENV["qiniu_access_key"]
    secret_key    = ENV["qiniu_secret_key"]
    callback_url  = ENV["qiniu_callback_url"]
    callback_body = ENV["qiniu_callback_body"]

    init_hash = { access_key:     access_key,
                  secret_key:     secret_key,
                  callback_url:   callback_url,
                  callback_body:  callback_body,
                  bucket:         params[:bucket],
                  key:            params[:key]
                }
    qiniu_client = QiniuCdn.new init_hash
    Cdn.new(qiniu_client)
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
