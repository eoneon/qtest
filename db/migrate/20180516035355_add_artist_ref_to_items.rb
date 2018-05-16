class AddArtistRefToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :artist_type, index: true
  end
end
