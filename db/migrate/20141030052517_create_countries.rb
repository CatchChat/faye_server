class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.string :phone_code

      t.timestamps
    end

    add_index :countries, :phone_code, unique: true
  end
end
