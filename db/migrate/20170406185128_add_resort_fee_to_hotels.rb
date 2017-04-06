class AddResortFeeToHotels < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :resortFee, :decimal
  end
end
