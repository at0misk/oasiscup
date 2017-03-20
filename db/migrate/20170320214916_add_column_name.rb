class AddColumnName < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :booked_rooms, :users
  end
end
