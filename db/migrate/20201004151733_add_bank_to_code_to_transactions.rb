class AddBankToCodeToTransactions < ActiveRecord::Migration[5.2]
  def change
    rename_column :account_transactions, :related_account, :bank_to_account
    add_column :account_transactions, :bank_to_code, :string
    add_column :account_transactions, :bank_from_code, :string
  end
end
