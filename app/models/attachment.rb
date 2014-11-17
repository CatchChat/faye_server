class Attachment < ActiveRecord::Base
  has_and_belongs_to_many :messages

  validates :file, presence: true
end
