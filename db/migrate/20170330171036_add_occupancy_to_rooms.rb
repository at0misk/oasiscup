class AddOccupancyToRooms < ActiveRecord::Migration[5.0]
  def change
  	add_column :rooms, :occupancy_a, :int
  end
end
