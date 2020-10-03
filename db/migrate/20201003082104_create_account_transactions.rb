class CreateAccountTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :account_transactions do |t|
      t.references :account, foreign_key: true
      t.string :related_account
      t.string :transaction_type
      t.string :status
      t.decimal :transefered_amount

      t.timestamps
    end
  end
end
