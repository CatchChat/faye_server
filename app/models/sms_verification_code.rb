class SmsVerificationCode < ActiveRecord::Base
  belongs_to :user

  def send_msg(content)
    send_sms(mobile,content)
  end

  private

  def send_sms(mobile, content)
    if phone_code == '86'
      sms.send_sms mobile: mobile, message: content
    else
      sms.send_sms mobile: "+#{phone_code}#{mobile}", message: content
    end

  end

  def sms
    if phone_code == '86'
      username         = ENV["luosimao_username"]
      apikey           = ENV["luosimao_apikey"]
      init_hash       = {username: username, apikey: apikey}
      luosimao_client = LuosimaoSms.new init_hash
      Sms.new(luosimao_client, init_hash)
    else
      key              = ENV["nexmo_key"]
      secret           = ENV["nexmo_secret"]
      init_hash       = {key: key, secret: secret}
      nexmo_client    = NexmoSms.new init_hash
      Sms.new(nexmo_client)
    end

  end
end
