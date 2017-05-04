class AddEmailHotelConfToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :email_hotel_conf, :boolean
  end
end
