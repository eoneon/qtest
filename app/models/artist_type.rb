class ArtistType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def full_name
    if properties
      first = properties["firstname"] if properties["firstname"].present?
      last = properties["lastname"] if properties["lastname"].present?
      [first, last].compact.join(" ")
    end
  end

  def dropdown
    category_names.map {|k| properties[k]}.join(" ")
  end

  def typ_ver_args(ver)
    ver == "body" ? "by #{dropdown}" : "#{dropdown},"
  end
end
