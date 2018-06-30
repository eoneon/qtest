class ChangeNumericFieldsInItems < ActiveRecord::Migration[5.1]
  def up
    change_table :items do |t|
      t.change :width, :string
      t.change :height, :string
      t.change :depth, :string
      t.change :weight, :string
    end
  end
  
  def down
    change_table :items do |t|
      t.change :width, :integer
      t.change :height, :integer
      t.change :depth, :integer
      t.change :weight, :integer
    end
  end
end
