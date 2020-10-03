class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.references :customer, foreign_key: true
      t.decimal :balance, :default => 0
      t.string :account_number

      t.timestamps
    end
  end
end
