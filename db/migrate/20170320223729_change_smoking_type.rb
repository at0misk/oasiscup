class ChangeSmokingType < ActiveRecord::Migration[5.0]
  def up
   change_column :rooms, :smoking, :boolean
  end

  def down
   change_column :rooms, :smoking, :string
  end
end
