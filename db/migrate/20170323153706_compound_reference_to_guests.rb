class CompoundReferenceToGuests < ActiveRecord::Migration[5.0]
  def change
    add_index :guests, [:user_id, :compoundname]
  end
end
