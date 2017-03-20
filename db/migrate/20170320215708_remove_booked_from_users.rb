class RemoveBookedFromUsers < ActiveRecord::Migration[5.0]
  def change
	remove_column :users, :booked_rooms_id
  end
end
