class CreateArtistTypes < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :artist_types do |t|
      t.hstore :properties
      
      t.timestamps
    end
  end
end
