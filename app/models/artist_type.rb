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

  def display_name
    if properties
      category_names.map {|k| properties[k]}.join(" ")
    end
  end

  def last_first
    if properties
      first = properties["firstname"] if properties["firstname"].present?
      last = properties["lastname"] if properties["lastname"].present?
      [last, first].compact.join(", ")
    end
  end

  def artistid
    if properties
      properties["adminid"]
    end
  end

  def dropdown
    #category_names.map {|k| properties[k]}.join(" ")
    last_first
  end

  def typ_ver_args(ver)
    ver == "body" ? "by #{display_name}" : "#{display_name},"
  end
end
