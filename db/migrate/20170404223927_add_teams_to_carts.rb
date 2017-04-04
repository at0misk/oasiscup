class AddTeamsToCarts < ActiveRecord::Migration[5.0]
  def change
	add_reference :carts, :team, foreign_key: true
	add_reference :books, :team, foreign_key: true
  end
end
