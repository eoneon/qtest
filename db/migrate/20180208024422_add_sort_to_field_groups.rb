class AddSortToFieldGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :field_groups, :sort, :integer
  end
end
