class CreateSmsVerificationCodes < ActiveRecord::Migration
  def change
    create_table :sms_verification_codes do |t|
      t.references :user, index: true
      t.string :mobile
      t.string :token
      t.datetime :expired_at
      t.boolean :active

      t.timestamps
    end
    add_index :sms_verification_codes, :token, length: 191
    add_index :sms_verification_codes, :mobile, length: 191
  end
end
