class DropBookedRooms < ActiveRecord::Migration[5.0]
  def change
  	drop_table :booked_rooms
  end
end
