class CreateUnfriendRequests < ActiveRecord::Migration
  def change
    create_table :unfriend_requests do |t|
      t.references :user, index: true
      t.references :friend, index: true

      t.timestamps
    end
  end
end
