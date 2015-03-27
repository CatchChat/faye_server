class AES256
  class << self
    def encrypt(data)
      cipher = OpenSSL::Cipher::AES.new(256, :CBC)
      cipher.encrypt
      cipher.key = ENV['AES256_KEY']
      cipher.iv  = ENV['AES256_IV']
      cipher.update(data) << cipher.final
    end

    def decrypt(data)
      cipher = OpenSSL::Cipher::AES.new(256, :CBC)
      cipher.decrypt
      cipher.key = ENV['AES256_KEY']
      cipher.iv  = ENV['AES256_IV']
      cipher.update(data) << cipher.final
    end
  end
end
