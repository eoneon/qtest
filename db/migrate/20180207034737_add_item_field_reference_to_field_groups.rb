class AddItemFieldReferenceToFieldGroups < ActiveRecord::Migration[5.1]
  def change
    add_reference :field_groups, :item_field, index: true
  end
end
