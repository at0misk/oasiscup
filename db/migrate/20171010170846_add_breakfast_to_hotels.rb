class AddBreakfastToHotels < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :breakfast, :string
  end
end
