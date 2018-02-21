class AddDimTypeRefToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :dim_type, index: true
  end
end
