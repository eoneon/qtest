class RemoveForeignKeysFromValueGroups < ActiveRecord::Migration[5.1]
  def change
    remove_index :value_groups, :item_fields_id
  end
end
