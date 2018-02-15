class AddDetailsToCertTypes < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :cert_types, :properties, :hstore
    add_reference :cert_types, :category, index: true
  end
end
