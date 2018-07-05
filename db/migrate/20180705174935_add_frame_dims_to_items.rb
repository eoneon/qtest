class AddFrameDimsToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :frame_width, :integer
    add_column :items, :frame_height, :integer
  end
end
