class AddTransactionCodeToTransaction < ActiveRecord::Migration[5.0]
  def change
  	add_column :transactions, :transaction_code, :string
  end
end
