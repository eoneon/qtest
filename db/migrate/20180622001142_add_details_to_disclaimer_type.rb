class AddDetailsToDisclaimerType < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :disclaimer_types, :properties, :hstore
    add_reference :disclaimer_types, :category, index: true
  end
end
