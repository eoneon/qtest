class AddCategoryReferenceToEditionTypes < ActiveRecord::Migration[5.1]
  def change
    add_reference :edition_types, :category, index: true
  end
end
