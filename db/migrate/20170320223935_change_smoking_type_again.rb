class ChangeSmokingTypeAgain < ActiveRecord::Migration[5.0]
  def up
   change_column :rooms, :smoking, :string
  end

  def down
   change_column :rooms, :smoking, :boolean
  end
end
