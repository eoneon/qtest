class AddMoreCsvDetailsToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :artistid, :integer
    add_column :items, :art_type, :string
    add_column :items, :medium, :string
    add_column :items, :material, :string
    add_column :items, :width, :integer
    add_column :items, :height, :integer
    add_column :items, :depth, :integer
    add_column :items, :weight, :integer
  end
end
