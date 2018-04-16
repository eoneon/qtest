class EditionType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def required_fields
    category_names.count == 1 ? category_names : category_names - ["edition"]
  end

  def edition
    case category.name
    when "edition_numbered_number_size" then ["numbered", h = {v: "edition numbered number/size"}]
    when "edition_numbered_size" then ["numbered out of", h = {v: "edition numbered out of size"}]
    when "edition_numbered" then ["numbered qty", h = {v: "edition numbered"}]
    when "edition" then ["from an edition", h = {occ: 0, pos: "after", pat: "from", v: "from edition edition", ws: 1}]
    when "unnumbered" then ["not numbered", "This piece is not numbered."] #category_names don't correspond to value -> hsh?/str?
    end
  end

  def dropdown
    edition[0]
  end

  def typ_ver_args(ver)
    edition[-1] if edition
  end
end
