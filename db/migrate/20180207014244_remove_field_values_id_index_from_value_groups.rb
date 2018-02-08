class RemoveFieldValuesIdIndexFromValueGroups < ActiveRecord::Migration[5.1]
  def change
    remove_index :value_groups, :field_values_id
  end
end
