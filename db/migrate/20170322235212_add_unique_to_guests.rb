class AddUniqueToGuests < ActiveRecord::Migration[5.0]
  def change
    add_column :guests, :compoundname, :string
  end
end
