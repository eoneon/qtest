class AddDetailsToSignTypes < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :sign_types, :properties, :hstore
    add_reference :sign_types, :category, index: true
  end
end
