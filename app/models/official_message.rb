class OfficialMessage < ActiveRecord::Base
  belongs_to :attachment

  validates :battery_level, inclusion: { in: 0..100 }
  enum media_type: %i(text photo video)
end
