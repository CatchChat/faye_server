class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.references :user, index: true
      t.string :token
      t.datetime :expired_at
      t.boolean :active
      t.string :creator_ip
      t.integer :push_provider
      t.integer :device

      t.timestamps
    end
  end
end
