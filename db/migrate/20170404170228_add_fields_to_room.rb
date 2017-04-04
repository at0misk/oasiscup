class AddFieldsToRoom < ActiveRecord::Migration[5.0]
  def change
  	add_column :rooms, :occupancy_c, :int
  	add_column :rooms, :description, :string
  end
end
