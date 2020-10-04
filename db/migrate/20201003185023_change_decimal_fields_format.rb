class ChangeDecimalFieldsFormat < ActiveRecord::Migration[5.2]
  def change
    change_column :account_transactions, :transefered_amount, :decimal, :precision => 10, :scale => 5

    change_column :accounts, :balance, :decimal, :precision => 10, :scale => 5

    change_column :bank_conditions, :commission, :decimal, :precision => 10, :scale => 5
    change_column :bank_conditions, :max_amount, :decimal, :precision => 10, :scale => 5
    change_column :bank_conditions, :min_amount, :decimal, :precision => 10, :scale => 5
  end
end
