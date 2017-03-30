class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.references :user, foreign_key: true
      t.float :total

      t.timestamps
    end
  end
end
