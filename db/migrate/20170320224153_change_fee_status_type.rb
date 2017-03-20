class ChangeFeeStatusType < ActiveRecord::Migration[5.0]
  def up
   change_column :users, :fee_status, :boolean
  end

  def down
   change_column :users, :fee_status, :string
  end
end
