class AddConfCodeToBooks < ActiveRecord::Migration[5.0]
  def change
  	add_column :books, :conf_code, :string
  end
end
