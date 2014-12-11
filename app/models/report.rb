class Report < ActiveRecord::Base
  belongs_to :message
  belongs_to :whistleblower, class_name: 'User'
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, polymorphic: true
  has_and_belongs_to_many :attachments
  has_many :individual_recipients, foreign_key: :message_id, primary_key: :message_id

  validates :message_id, uniqueness: { scope: :whistleblower_id }
end
