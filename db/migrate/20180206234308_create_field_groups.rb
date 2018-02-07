class CreateFieldGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :field_groups do |t|
      t.references :item_fields
      t.references :classifiable, polymorphic: true

      t.timestamps
    end
  end
end
