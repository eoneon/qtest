class AddCsvInvoiceToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :invoice_tag, :string
  end
end
