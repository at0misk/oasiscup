class ChangeGuestTypeName < ActiveRecord::Migration[5.0]
  def change
  	rename_column :guests, :type, :guest_type
  end
end
