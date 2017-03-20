class RenameBookedAgain < ActiveRecord::Migration[5.0]
  def change
     rename_table :booked, :books
  end
end
