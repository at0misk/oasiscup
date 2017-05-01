class AddDownPaymentStatusToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :down_payment_status, :boolean
  end
end
