class AddInvoiceRefToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :invoice, index: true
  end
end
