class CreateConfirmations < ActiveRecord::Migration[5.0]
  def change
    create_table :confirmations do |t|
      t.string :number
      t.string :team

      t.timestamps
    end
  end
end
