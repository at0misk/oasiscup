class AddMailerConfirmationToTeams < ActiveRecord::Migration[5.0]
  def change
  	add_column :teams, :mail_confirmation, :boolean
  end
end
