class AddMountRefToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :mount_type, index: true
  end
end
