class AddFeeStatusToTeams < ActiveRecord::Migration[5.0]
  def change
  	add_column :teams, :fee_status, :string
  end
end
