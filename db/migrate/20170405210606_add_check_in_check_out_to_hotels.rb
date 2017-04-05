class AddCheckInCheckOutToHotels < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :checkin, :string
  	add_column :hotels, :checkout, :string
  end
end
