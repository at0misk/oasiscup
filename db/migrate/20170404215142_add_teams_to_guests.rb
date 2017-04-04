class AddTeamsToGuests < ActiveRecord::Migration[5.0]
  def change
	add_reference :guests, :team, foreign_key: true
  end
end
