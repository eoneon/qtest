class CreateInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoices do |t|
      t.integer :invoice
      t.string :name

      t.timestamps
    end
  end
end
