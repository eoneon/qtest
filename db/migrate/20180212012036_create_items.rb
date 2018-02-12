class CreateItems < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :items do |t|
      t.hstore :properties
      t.references :item_type
      t.references :edition_type

      t.timestamps
    end
    add_index :items, :properties, using: :gist
  end
end
