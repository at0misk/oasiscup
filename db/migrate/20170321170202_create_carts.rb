class CreateCarts < ActiveRecord::Migration[5.0]
  def change
    create_table :carts do |t|
      t.float :price
      t.string :number
      t.string :smoking
      t.string :room_type
      t.references :hotel, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
