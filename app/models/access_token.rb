class AccessToken < ActiveRecord::Base
  belongs_to :user

  def can_use?
    active? && (expired_at.nil? || expired_at > Time.now)
  end
end
