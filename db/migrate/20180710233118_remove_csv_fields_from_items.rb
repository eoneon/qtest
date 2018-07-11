class RemoveCsvFieldsFromItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :items, :artist
    remove_column :items, :artistid
    remove_column :items, :art_type
    remove_column :items, :medium
    remove_column :items, :material
    remove_column :items, :width
    remove_column :items, :height
    remove_column :items, :depth
    remove_column :items, :weight
    remove_column :items, :frame_width
    remove_column :items, :frame_height
    remove_column :items, :tagline
    remove_column :items, :property_room
    remove_column :items, :description
  end
end
