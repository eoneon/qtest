class RemoveItemFieldsIdFromValuegroups < ActiveRecord::Migration[5.1]
  def change
    remove_column :value_groups, :item_fields_id
  end
end
