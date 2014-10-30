class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.string :phone_code

      t.timestamps
    end
  end
end
