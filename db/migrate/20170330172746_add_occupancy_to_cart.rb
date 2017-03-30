class AddOccupancyToCart < ActiveRecord::Migration[5.0]
  def change
  	add_column :carts, :occupancy_a, :int
  end
end
