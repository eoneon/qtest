class AddDetailsToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :sign_type, index: true
    add_reference :items, :cert_type, index: true
  end
end
