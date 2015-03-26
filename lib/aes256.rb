class AES256
  class << self
    def encrypt(data)
      cipher = OpenSSL::Cipher::AES.new(256, :CBC)
      cipher.encrypt
      # FIXME
      cipher.key = "w\u009E\u0083\u0000éfÆWÉ\u0006\t®ªæm\u0098\u00118l\u001F¤êþC\u0006°Uw±Wci"
      cipher.iv  = "EKø«CtálÔ\u0097\u000FoÆ\v%n"
      cipher.update(data) << cipher.final
    end

    def decrypt(data)
      cipher = OpenSSL::Cipher::AES.new(256, :CBC)
      cipher.decrypt
      # FIXME
      cipher.key = "w\u009E\u0083\u0000éfÆWÉ\u0006\t®ªæm\u0098\u00118l\u001F¤êþC\u0006°Uw±Wci"
      cipher.iv  = "EKø«CtálÔ\u0097\u000FoÆ\v%n"
      cipher.update(data) << cipher.final
    end
  end
end
