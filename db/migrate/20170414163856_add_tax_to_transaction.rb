class AddTaxToTransaction < ActiveRecord::Migration[5.0]
  def change
  	add_column :transactions, :tax, :decimal
  end
end
