class AddCategoryReferenceToItemTypes < ActiveRecord::Migration[5.1]
  def change
    add_reference :item_types, :category, index: true
  end
end
