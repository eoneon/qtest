class CreateMountTypes < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :mount_types do |t|
      t.hstore :properties
      t.string :name
      
      t.timestamps
    end
  end
end
