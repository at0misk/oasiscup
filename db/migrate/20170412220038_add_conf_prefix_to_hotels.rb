class AddConfPrefixToHotels < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :conf_prefix, :string
  end
end
