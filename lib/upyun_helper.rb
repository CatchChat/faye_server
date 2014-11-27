module UpyunHelper
  def self.client
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
end
