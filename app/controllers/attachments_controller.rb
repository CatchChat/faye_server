class AttachmentsController < ApiController
  skip_before_action :authenticate_user, only: [:callback, :public_callback]

  def s3_upload_form_fields
    raise Cdn::MissingParam, "missing params for upload token" unless @message = Message.find_by(id: params[:id].to_i)
    @provider = 's3'
    @cdn = S3Helper.client
    key = SecureRandom.uuid
    @url, @policy, @encoded_policy, @signature = @cdn.get_upload_form_url_fields key: key
    # create attachment record here because S3 event can't add info about the
    # message, need to set message's state when s3 notify the file is uploaded
    attachment = Attachment.find_or_create_by! storage: @provider, file: key
  end

  def upload_token
    raise Cdn::MissingParam, "missing params for upload token" unless @message = Message.find_by(id: params[:id].to_i)
    @provider = 'qiniu'
    @cdn = QiniuHelper.client
    @token = @cdn.get_upload_token key: SecureRandom.uuid

  rescue Cdn::MissingParam => e
    render json: {error: e.message}, status: :not_acceptable
  end

  def public_upload_token
    @provider = 'qiniu'
    @cdn = QiniuHelper.avatar_client
    key =  SecureRandom.uuid
    @token = @cdn.get_upload_token key: key
    @download_url = QiniuHelper.public_url(key)

  rescue Cdn::MissingParam => e
    render json: {error: e.message}, status: :not_acceptable
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
      TransferAttachmentsJob.perform_async attachment.attributes.except(*%w{updated_at created_at})
      @message.attachments << attachment
      @message.mark_as_unread
      MessageNotificationJob.perform_async(@message.id)

      render json: {provider: 'qiniu', file: key, message_id: @message.id, attachment_id: attachment.id}
    end
    if provider == 'upyun'
      key = params[:url]
      _attachment = Attachment.find_or_create_by! storage: provider,  file: key
      render json: {provider: 'upyun', file: key}
    end
  rescue Cdn::MissingParam => e
    render json: {error: e.message}, status: :not_acceptable
  end

  def public_callback
    provider = params[:provider]
    raise Cdn::MissingParam, "provider is not supported" unless provider == 'qiniu'

    if provider == 'qiniu'
      # TODO: verify request come from qiniu
      key = params[:key]
      attachment = Attachment.find_or_create_by! storage: provider,  file: key, public: true
      # TODO: the method could change in rails 4.2
      TransferAttachmentsJob.perform_async attachment.attributes.except *%w{updated_at created_at}
    end
      render json: {provider: 'qiniu', file: key, attachment_id: attachment.id}
  end

end
