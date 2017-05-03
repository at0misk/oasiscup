class AddAgreeToUsers < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :agree, :boolean
  end
end
