class AddReferencesToValueGroups < ActiveRecord::Migration[5.1]
  def change
    add_reference :value_groups, :item_field, index: true
    add_reference :value_groups, :field_value, index: true
  end
end
