class ChangeFloatsToDecs < ActiveRecord::Migration[5.0]
  def self.up
   change_column :rooms, :price, :decimal
   change_column :books, :price, :decimal
   change_column :carts, :price, :decimal
  end
  def self.down
   change_column :rooms, :price, :float
   change_column :books, :price, :float
   change_column :carts, :price, :float
  end
end
