class AddCategoryRefToArtistTypes < ActiveRecord::Migration[5.1]
  def change
    add_reference :artist_types, :category, index: true
  end
end
