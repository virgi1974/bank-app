class CreateTaBankRegisters < ActiveRecord::Migration[5.2]
  def change
    create_table :ta_bank_registers do |t|
      t.string :name
      t.string :bank_number
      t.string :host

      t.timestamps
    end
  end
end
