class EditionType < ApplicationRecord
  belongs_to :category

  def category_names
    category.name.split("_")
  end

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def from_edition
    if properties["numbering"] == "from edition"
      n = properties["numbering"].split(" ")
      article = article_list.any? {|word| word == properties["edition"]} ? "an" : "a"
      [n[0], article, properties["edition"], n[1]].join(" ")
    end
  end

  def numbered
    if properties["numbering"] == "numbered" && properties["number"].present? && properties["size"].present?
      "#{properties["edition"]} #{properties["numbering"]} #{properties["number"]}/#{properties["size"]}"
    end
  end

  def numbered_qty
    if properties["numbering"] == "numbered" && properties["number"].blank? && properties["size"].blank?
      "#{properties["edition"]} #{properties["numbering"]}"
    end
  end

  def not_numbered
    if properties["numbering"] == "not numbered"
      "This piece is not numbered."
    end
  end

  def edition_description
    case
    when properties["numbering"] == "from edition" then from_edition
    when properties["numbering"] == "numbered" && properties["number"].present? && properties["size"].present? then numbered
    when properties["numbering"] == "numbered" && properties["number"].blank? && properties["size"].blank? then numbered_qty
    when properties["numbering"] == "not numbered" then not_numbered
    end
  end
end
