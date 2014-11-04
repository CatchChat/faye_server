class CreateSmsVerificationCodes < ActiveRecord::Migration
  def change
    create_table :sms_verification_codes do |t|
      t.references :user, index: true
      t.datetime :expired_at
      t.boolean :active

      t.timestamps
    end
  end
end
