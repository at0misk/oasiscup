class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :team
      t.string :fee_status
      t.string :password_digest

      t.timestamps
    end
  end
end
