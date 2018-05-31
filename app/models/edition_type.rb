class EditionType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def required_fields
    category_names.count == 1 ? category_names : category_names - ["edition"]
  end

  def edition_context
    category.name == "edition" ? "from_edition" : "not_from_edition"
  end

  # def edition
  #   case category.name
  #   when "edition_numbered_number_size" then ["numbered", h = {v: "edition numbered number/size"}]
  #   when "edition_numbered_size" then ["numbered out of", h = {v: "edition numbered out of size"}]
  #   when "edition_numbered" then ["numbered qty", h = {v: "edition numbered"}]
  #   when "edition" then ["from an edition", h = {occ: 0, pos: "after", pat: "from", v: "from edition edition", ws: 1}]
  #   when "unnumbered" then ["not numbered", "This piece is not numbered."]
  #   #when "unnumbered" then ["not numbered", h = {v: "This piece is not numbered."}]
  #   end
  # end

  def edition_numbered_number_size
    ["numbered", "edition numbered number/size"]
  end

  def edition_numbered_size
    ["numbered out of", "edition numbered out of size"]
  end

  def edition_numbered
    ["numbered qty", "edition numbered"]
  end

  def edition
    ["from an edition", "from edition edition"]
  end

  def unnumbered
    ["not numbered", "This piece is not numbered"]
  end

  def dropdown
    #edition[0]
    public_send(category.name)[0]
  end

  def typ_ver_args(ver)
    #edition[-1] if edition
    public_send(category.name)[1]
  end
end
