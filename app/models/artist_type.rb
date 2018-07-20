class ArtistType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def self.last_name
    #https://stackoverflow.com/questions/46076232/how-to-pluck-hstore-key-with-activerecord?rq=1
    ArtistType.order("properties -> 'lastname'")
  end

  def valid_key?(k)
    properties && category_names.include?(k)
  end

  def full_name
    category_names.map {|k| properties[k] if valid_key?(k) && k != "dob"}.join(" ")
  end

  def display_name
    category_names.map {|k| properties[k] if valid_key?(k)}.join(" ")
  end

  def last_first
    full_name.split.reverse.join(", ")
  end

  def artistid
    if properties
      properties["adminid"]
    end
  end

  def dropdown
    last_first
  end

  def typ_ver_args(ver)
    ver == "body" ? "by #{display_name}" : "#{display_name},"
  end
end
