class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :idn
      t.references :bank, foreign_key: true

      t.timestamps
    end
  end
end
