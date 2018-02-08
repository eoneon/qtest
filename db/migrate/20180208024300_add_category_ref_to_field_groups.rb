class AddCategoryRefToFieldGroups < ActiveRecord::Migration[5.1]
  def change
    add_reference :field_groups, :category, index: true
  end
end
