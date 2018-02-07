class CreateItemFields < ActiveRecord::Migration[5.1]
  def change
    create_table :item_fields do |t|
      t.string :name
      t.string :field_type
      t.string :kind

      t.timestamps
    end
  end
end
