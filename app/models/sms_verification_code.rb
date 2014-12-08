class SmsVerificationCode < ActiveRecord::Base
  belongs_to :user

  def send_msg(content)
    send_sms(mobile,content)
  end

  def self.verify_token(sms_code_query)
    if (sms_code = find_by(sms_code_query)) && sms_code.active == true && (!sms_code.expired_at or sms_code.expired_at > Time.now)
      user = sms_code.user
      user.mobile_verified = true
      sms_code.active = false
      sms_code.save
      user.save
      user
    end


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
      Sms.new(luosimao_client)
    else
      key              = ENV["nexmo_key"]
      secret           = ENV["nexmo_secret"]
      init_hash       = {key: key, secret: secret}
      nexmo_client    = NexmoSms.new init_hash
      Sms.new(nexmo_client)
    end

  end
end
