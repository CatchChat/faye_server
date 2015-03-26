class AES256
  class << self
    def encrypt(data)
      cipher = OpenSSL::Cipher::AES.new(256, :CBC)
      cipher.encrypt
      cipher.key = "w\x9E\x83\x00\xE9f\xC6W\xC9\x06\t\xAE\xAA\xE6m\x98\x118l\x1F\xA4\xEA\xFEC\x06\xB0Uw\xB1Wci"
      cipher.iv  = "EK\xF8\xABCt\xE1l\xD4\x97\x0Fo\xC6\v%n"
      cipher.update(data) << cipher.final
    end

    def decrypt(data)
      cipher = OpenSSL::Cipher::AES.new(256, :CBC)
      cipher.decrypt
      cipher.key = "w\x9E\x83\x00\xE9f\xC6W\xC9\x06\t\xAE\xAA\xE6m\x98\x118l\x1F\xA4\xEA\xFEC\x06\xB0Uw\xB1Wci"
      cipher.iv  = "EK\xF8\xABCt\xE1l\xD4\x97\x0Fo\xC6\v%n"
      cipher.update(data) << cipher.final
    end
  end
end
