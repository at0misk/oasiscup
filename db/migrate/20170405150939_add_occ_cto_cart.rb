class AddOccCtoCart < ActiveRecord::Migration[5.0]
  def change
  	add_column :carts, :occupancy_c, :int
  	add_column :books, :occupancy_c, :int
  end
end
