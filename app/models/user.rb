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
  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name), allow_nil: true }

  attr_accessor :login

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :groups, foreign_key: 'owner_id', dependent: :destroy
  has_many :individual_recipients, dependent: :destroy
  has_many :access_tokens, :dependent => :delete_all
  has_many :sms_verification_codes, :dependent => :delete_all
  has_many :friend_requests, dependent: :destroy
  has_many :received_friend_requests, foreign_key: 'friend_id', class_name: 'FriendRequest'
  has_many :unfriend_requests, dependent: :destroy
  has_many :messages, dependent: :destroy, foreign_key: :sender_id
  has_many :individual_recipients
  has_many :received_messages, through: :individual_recipients, source: :message
  has_many :unread_messages, -> {
    where.not(individual_recipients: { state: IndividualRecipient::STATES[:read] })
  }, through: :individual_recipients, source: :message
  has_many :contacts, dependent: :destroy
  has_many :reports, foreign_key: :whistleblower_id

  scope :mobile_verified, -> { where(User.table_name => { mobile_verified: true }) }
  scope :active, -> { where(User.table_name => { state: STATES[:active] }) }

  before_create :generate_pusher_id

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

  def normalized_mobile
    "+#{phone_code}#{mobile}"
  end

  def name_by_friend(friend, not_friend = false)
    if !not_friend && (friendship = friendships.find_by(friend_id: friend.id))
      friend_name = friendship.remarked_name.presence || friendship.contact_name.presence
    end

    friend_name || contact_name_by_friend(friend) || self.name
  end

  def contact_name_by_friend(friend)
    return if !mobile_verified || mobile.blank?

    if contact = Contact.by_user(friend.id).by_number(normalized_mobile).first
      contact.name.presence
    end
  end

  def current_admin
    current_user.admin
  end


  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def official_account?
    Settings.official_accounts.include?(self.username)
  end

  def report_message(message)
    attributes = message.attributes.except('updated_at', 'created_at', 'id')
    report = self.reports.new(attributes)
    report.message = message
    report.attachments = message.attachments
    if report.save && report.attachments.present?
      report.attachments.update_all(reserved: true)
    end
    report
  end

  def push_joined_notification
    return if !mobile_verified || mobile.blank?

    Contact.by_number(normalized_mobile).includes(:user).distinct(:user_id).
      where.not(user_id: self.id).each do |contact|
      Pusher.push_to_user(
        contact.user,
        content: I18n.t(
          'notification.contact_registered',
          contact_name: contact.name,
          username: self.username
        ),
        extras: { type: 'contact_join' }
      )
    end
  end

  private

  def generate_pusher_id
    return if self.pusher_id
    self.pusher_id = BSON::ObjectId.new.to_s
  end
end
