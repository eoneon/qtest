class Item < ApplicationRecord
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def from_edition
    article = article_list.any? {|word| word == properties["edition"]} ? "an" : "a"
    ["from", article, properties["edition"], "edition"].join(" ")
  end

  def numbered
    [properties["edition"], properties["numbered"], "#{properties["number"]}/#{properties["size"]}"].join(" ")
  end

  def numbered_qty
    [properties["edition"], properties["numbered"]].join(" ")
  end

  def numbered_from
    [properties["edition"], properties["numbered"], "out of", properties["size"]].join(" ")
  end

  def not_numbered
    "This piece is not numbered."
  end

  def edition_description
    case
    when edition_type.name == "edition" && properties["edition"].present? then from_edition
    when edition_type.name == "edition_numbered_number_size" && properties["numbered"].present? && properties["number"].present? && properties["size"].present? then numbered
    when edition_type.name == "edition_numbered" && properties["numbered"].present? && properties["number"].blank? && properties["size"].blank? then numbered_qty
    when edition_type.name == "edition_numbered_size" && properties["numbered"].present? && properties["size"].present? then numbered_from
    when edition_type.name == "not numbered" then not_numbered
    end
  end
end
