require 'node_password'
class User < ActiveRecord::Base
  extend NodePassword
  include Redis::Objects
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :encryptable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { in: 4..16 },
                       format: { with: /\A[a-zA-Z0-9]+\z/ }

  attr_accessor :login

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :groups, foreign_key: 'owner_id', dependent: :destroy
  belongs_to :country
  has_many :individual_recipients, dependent: :destroy
  has_many :access_tokens, :dependent => :delete_all
  has_many :sms_verification_codes, :dependent => :delete_all
  has_many :sent_friend_requests, dependent: :destroy, class_name: 'FriendRequest'
  has_many :received_friend_requests, foreign_key: 'friend_id', class_name: 'FriendRequest'
  has_many :unfriend_requests, dependent: :destroy
  has_many :sent_messages, dependent: :destroy, class_name: 'Message', foreign_key: :sender_id
  has_many :individual_recipients
  has_many :received_messages, through: :individual_recipients, source: :message
  has_many :unread_messages, -> {
    where.not(individual_recipients: { state: IndividualRecipient::STATES[:read] })
  }, through: :individual_recipients, source: :message

  STATES = { active: 1, blocked: 2 }.freeze

  state_machine :state, initial: :active do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :block do
      transition active: :blocked
    end

    event :unblock do
      transition blocked: :active
    end
  end

  def generate_token
    "#{Devise.friendly_token}#{Time.now.to_f}"
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

  def name
    nickname.presence || username
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.create_friendships(user_id, friend_id)
    # TODO: Add contact_name after find contacts
    Friendship.transaction do
      begin
        Friendship.create!(user_id: user_id, friend_id: friend_id)
        Friendship.create!(friend_id: user_id, user_id: friend_id)
        return true
      rescue => ex
        logger.debug "===> #{ex}"
        raise ActiveRecord::Rollback
        return false
      end
    end
  end

  def self.unfriend(user_id, friend_id)
    Friendship.where(
      '(user_id = :user_id AND friend_id = :friend_id) OR (user_id = :friend_id AND friend_id = :user_id)',
      user_id: user_id, friend_id: friend_id
    ).destroy_all
  end
end
