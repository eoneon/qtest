class AddSkuToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :sku, :integer
  end
end
