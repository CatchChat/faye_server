require 'node_password'
class User < ActiveRecord::Base
  extend NodePassword
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
  belongs_to :country
  has_many :individual_recipients

  STATES = { active: 0, blocked: 1 }.freeze

  state_machine :state, initial: :active do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :active do
      transition blocked: :active
    end

    event :blocked do
      transition active: :blocked
    end
  end

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

  def unread_messages
    Message.joins(:individual_recipients).
      where(individual_recipients: { state: IndividualRecipient::STATES[:delivered], user_id: self.id })
  end

end
