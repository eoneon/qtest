class RemoveFieldValuesIdFromValueGroups < ActiveRecord::Migration[5.1]
  def change
    remove_column :value_groups, :field_values_id
  end
end
