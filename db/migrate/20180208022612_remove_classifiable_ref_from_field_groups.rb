class RemoveClassifiableRefFromFieldGroups < ActiveRecord::Migration[5.1]
  def change
    remove_column :field_groups, :classifiable_id
    remove_column :field_groups, :classifiable_type
  end
end
