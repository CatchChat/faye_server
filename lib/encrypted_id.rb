require_relative 'aes256'
module EncryptedID

  def self.included(base)
    base.extend  ClassMethods
    base.include InstanceMethods
  end

  module InstanceMethods
    def encrypted_id
      return @encrypted_id if defined? @encrypted_id
      return unless self.id
      @encrypted_id = self.class.encrypt_id(self.id)
    end
  end

  module ClassMethods
    def encrypt_id(id)
      return if id.blank?
      AES256.encrypt(id.to_s).unpack('H*').first
    end

    def decrypt_id(encrypted_id)
      return if encrypted_id.blank?
      AES256.decrypt([encrypted_id].pack('H*')).to_i rescue nil
    end
  end
end

ActiveRecord::Base.send :include, EncryptedID
