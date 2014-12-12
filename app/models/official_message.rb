class OfficialMessage < ActiveRecord::Base
  has_and_belongs_to_many :attachments

  validates :battery_level, inclusion: { in: 0..100 }
  enum media_type: %i(text photo video)
end
