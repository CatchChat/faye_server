class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :encryptable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { in: 4..16 },
                       format: { with: /\A[a-zA-Z0-9]+\z/ }

  attr_accessor :login

  has_many :friendships
  has_many :friends, through: :friendships
  has_many :groups, foreign_key: 'owner_id'
  has_many :messages

  belongs_to :country

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.username
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
end
