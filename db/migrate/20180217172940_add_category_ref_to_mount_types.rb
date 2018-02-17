class AddCategoryRefToMountTypes < ActiveRecord::Migration[5.1]
  def change
    add_reference :mount_types, :category, index: true
  end
end
