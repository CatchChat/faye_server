class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :user, index: true
      t.string :name
      t.string :encrypted_number

      t.timestamps
    end

    add_index :contacts, :encrypted_number, length: 191
  end
end
