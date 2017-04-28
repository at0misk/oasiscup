class AddShelvedToHotels < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :shelved, :boolean
  end
end
