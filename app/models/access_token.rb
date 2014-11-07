class AccessToken < ActiveRecord::Base
  belongs_to :user

  enum client: [:official, :company, :local]
end
