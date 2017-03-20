class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.float :price
      t.string :number
      t.boolean :smoking
      t.string :type
      t.references :hotel, foreign_key: true

      t.timestamps
    end
  end
end
