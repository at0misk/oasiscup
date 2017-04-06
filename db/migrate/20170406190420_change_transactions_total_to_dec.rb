class ChangeTransactionsTotalToDec < ActiveRecord::Migration[5.0]
  def self.up
   change_column :transactions, :total, :decimal
   change_column :reservations, :total, :decimal
  end
  def self.down
   change_column :transactions, :total, :float
   change_column :reservations, :total, :float
  end
end
