class AddPaidToBooks < ActiveRecord::Migration[5.0]
  def change
  	add_column :books, :paid_status, :boolean
  end
end
