class Contact < ActiveRecord::Base
  include PhoneNumberParser
  belongs_to :user

  before_validation :encrypt_number, on: :create
  validates :name, :encrypted_number, :user_id, presence: true
  validates :encrypted_number, uniqueness: { scope: :user_id, allow_blank: true }

  attr_accessor :number

  scope :by_number, ->(number) { where(self.table_name => { encrypted_number: encrypt_number(number) }) }
  scope :by_user, -> (user) { where(self.table_name => { user_id: user.is_a?(User) ? user.id : user }) }

  # From NodeJS
  # sha256ed(salted(sha256ed(_str)))
  #
  # salt = crypto.createHash('sha256').update('CatchChat').digest('hex')
  # salted = (_str='', _salt=salt) ->
  #   return _.flatten(_.zip(_str,_salt)).toString().replace(/\,/g,'')
  def self.encrypt_number(number)
    number = number.to_s
    country_code, pure_number = parse(number)
    country_code  = '86' if country_code.blank?
    full_number   = "+#{country_code}#{pure_number}"
    sha256_number = Digest::SHA256.hexdigest(full_number)
    slat          = Digest::SHA256.hexdigest('CatchChat')
    slated_str    = sha256_number.chars.zip(slat.chars).join.gsub(/\,/, '')
    Digest::SHA256.hexdigest(slated_str)
  end

  def encrypt_number
    self.encrypted_number = self.class.encrypt_number(number) if number.present?
  end
end
