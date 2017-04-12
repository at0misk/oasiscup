class AddTransactionsToBooks < ActiveRecord::Migration[5.0]
  def change
	add_reference :books, :transaction, index: true
  end
end
