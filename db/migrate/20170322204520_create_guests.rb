class CreateGuests < ActiveRecord::Migration[5.0]
  def change
    create_table :guests do |t|
      t.string :first
      t.string :last
      t.string :type
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
