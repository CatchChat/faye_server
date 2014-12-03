class SmsVerificationCode < ActiveRecord::Base
  belongs_to :user

  def send_msg(content)
    send_sms(mobile,content)
  end

  private

  def send_sms(mobile, content)
    code, body = sms.send_sms mobile: mobile, message: content
    #return true if code == 200 && body == "{\"error\":0,\"msg\":\"ok\"}"
    [code, body]
  end

  def sms
    username         = ENV["luosimao_username"]
    apikey           = ENV["luosimao_apikey"]
    init_hash       = {username: username, apikey: apikey}
    luosimao_client = LuosimaoSms.new init_hash
    Sms.new(luosimao_client, init_hash)
  end
end
