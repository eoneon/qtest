class AddRetailToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :retail, :integer
  end
end
