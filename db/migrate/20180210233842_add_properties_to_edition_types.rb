class AddPropertiesToEditionTypes < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :edition_types, :properties, :hstore
  end
end
