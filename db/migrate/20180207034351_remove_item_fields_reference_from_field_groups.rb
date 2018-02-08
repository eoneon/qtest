class RemoveItemFieldsReferenceFromFieldGroups < ActiveRecord::Migration[5.1]
  def change
    remove_index :field_groups, :item_fields_id
    remove_column :field_groups, :item_fields_id
  end
end
