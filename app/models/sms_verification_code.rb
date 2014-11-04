class SmsVerificationCode < ActiveRecord::Base
  belongs_to :user
end
