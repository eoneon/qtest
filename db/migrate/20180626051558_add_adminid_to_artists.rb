class AddAdminidToArtists < ActiveRecord::Migration[5.1]
  def change
    add_column :artist_types, :adminid, :integer
  end
end
