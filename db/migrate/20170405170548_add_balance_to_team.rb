class AddBalanceToTeam < ActiveRecord::Migration[5.0]
  def change
  	add_column :teams, :balance, :decimal
  end
end
