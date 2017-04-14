class CreateTbooks < ActiveRecord::Migration[5.0]
  def change
    create_table :tbooks do |t|
      t.decimal :price
      t.string :number
      t.string :smoking
      t.string :room_type
      t.references :hotel, foreign_key: true
      t.references :user, foreign_key: true
      t.references :team, foreign_key: true
      t.integer :occupancy_a
      t.integer :occupancy_c
      t.boolean :paid_status
      t.string :conf_code
      t.references :transaction, foreign_key: true

      t.timestamps
    end
  end
end
