class AddFieldsToHotel < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :lat, :decimal
  	add_column :hotels, :long, :decimal
  	add_column :hotels, :phone, :string
  end
end
