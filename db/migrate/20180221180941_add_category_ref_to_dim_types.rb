class AddCategoryRefToDimTypes < ActiveRecord::Migration[5.1]
  def change
    add_reference :dim_types, :category, index: true
  end
end
