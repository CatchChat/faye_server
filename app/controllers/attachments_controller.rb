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
  end

  # GET /api/attachments/download\_token/:provider
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
    @cdn          = Cdn.new(qiniu_client)
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
    @cdn          = Cdn.new(upyun_client)
  end

  def init_s3_cdn
    # TODO implement s3
  end
end
