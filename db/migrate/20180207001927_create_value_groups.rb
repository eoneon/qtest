class CreateValueGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :value_groups do |t|
      t.references :item_fields
      t.references :field_values

      t.timestamps
    end
  end
end
