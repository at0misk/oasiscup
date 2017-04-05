class AddExemptToTeams < ActiveRecord::Migration[5.0]
  def change
  	add_column :teams, :exempt, :boolean
  end
end
