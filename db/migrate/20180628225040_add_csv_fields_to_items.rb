class AddCsvFieldsToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :artist, :string
    add_column :items, :tagline, :string
    add_column :items, :property_room, :string
    add_column :items, :description, :string
  end
end
