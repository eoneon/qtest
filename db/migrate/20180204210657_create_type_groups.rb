class CreateTypeGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :type_groups do |t|
      t.references :classifiable, polymorphic: true
      t.references :typeable, polymorphic: true

      t.timestamps
    end
  end
end
