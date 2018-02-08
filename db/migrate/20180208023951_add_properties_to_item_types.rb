class AddPropertiesToItemTypes < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :item_types, :properties, :hstore

    add_index :item_types, :properties, using: :gist
  end
end
