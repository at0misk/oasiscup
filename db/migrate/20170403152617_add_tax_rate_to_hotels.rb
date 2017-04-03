class AddTaxRateToHotels < ActiveRecord::Migration[5.0]
  def change
  	add_column :hotels, :tax, :decimal
  end
end
