class ArtistType < ApplicationRecord
  include SharedMethods

  #store_accessor :properties, :lastname, :firstname

  belongs_to :category
  has_many :items

  #scope :last_names, -> {order("properties ? :key", key: "lastname")}
  def self.last_name
    #https://stackoverflow.com/questions/46076232/how-to-pluck-hstore-key-with-activerecord?rq=1
    #ArtistType.pluck(:properties, :id).map {|name, id| [[name['lastname'], name['firstname']].compact.join(", "), id]}.sort
    #ArtistType.all.order(:properties['lastname']).pluck(:id)
    #ArtistType.all.order(:properties['lastname']).pluck(:properties['lastname'])
    #ArtistType.all.sort
    #winner!
    ArtistType.order("properties -> 'lastname'").pluck(:id)
  end

  # def ordered
  #
  # end

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
