class ArtistType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def dropdown
    category_names.map {|k| properties[k]}.join(" ")
  end

  def typ_ver_args(ver)
    #ver == "body" ? h = {pos: "after", v: "by #{dropdown}" occ: 0, ws: 1} : "#{dropdown},"
    ver == "body" ? "by #{dropdown}" : "#{dropdown},"
  end
end
