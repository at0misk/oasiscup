class AddDescriptionAndWebsiteToHotels < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :description, :string
  	add_column :hotels, :website, :string
  end
end
