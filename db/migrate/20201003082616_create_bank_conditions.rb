class CreateBankConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_conditions do |t|
      t.references :bank, foreign_key: true
      t.string :external_bank_number
      t.decimal :commission, :default => 0
      t.decimal :max_amount, :default => 1000
      t.decimal :min_amount, :default => 1
      t.string :transaction_type

      t.timestamps
    end
  end
end

