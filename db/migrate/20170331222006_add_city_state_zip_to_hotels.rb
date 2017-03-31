class AddCityStateZipToHotels < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :city, :string
  	add_column :hotels, :state, :string
  	add_column :hotels, :zip, :string
  end
end
