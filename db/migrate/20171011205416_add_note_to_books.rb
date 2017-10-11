class AddNoteToBooks < ActiveRecord::Migration[5.0]
  def change
  	add_column :books, :note, :string
  end
end
