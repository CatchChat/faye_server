class AccessToken < ActiveRecord::Base
  belongs_to :user

  enum client: [:official, :company, :local]

  def self.current=(token)
    @current = token
  end

  def self.current
    @current
  end
end
