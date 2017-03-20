class ChangeSmokingTypeOnBooks < ActiveRecord::Migration[5.0]
  def up
   change_column :books, :smoking, :string
  end

  def down
   change_column :books, :smoking, :boolean
  end
end
