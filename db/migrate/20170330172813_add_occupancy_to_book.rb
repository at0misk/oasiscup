class AddOccupancyToBook < ActiveRecord::Migration[5.0]
  def change
  	add_column :books, :occupancy_a, :int
  end
end
