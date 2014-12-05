class AddPhoneCodeToSmsVerificationCode < ActiveRecord::Migration
  def change
    add_column :sms_verification_codes, :phone_code, :string, default: '86'
  end
end
