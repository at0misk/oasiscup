class RenameBooked < ActiveRecord::Migration[5.0]
  def change
     rename_table :booked_rooms, :books
  end
end
