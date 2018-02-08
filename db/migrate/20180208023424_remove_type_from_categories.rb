class RemoveTypeFromCategories < ActiveRecord::Migration[5.1]
  def change
    remove_column :categories, :type
  end
end
