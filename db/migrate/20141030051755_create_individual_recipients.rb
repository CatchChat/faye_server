class CreateIndividualRecipients < ActiveRecord::Migration
  def change
    create_table :individual_recipients do |t|
      t.references :message, index: true
      t.references :user, index: true
      t.integer :state

      t.timestamps
    end
  end
end
