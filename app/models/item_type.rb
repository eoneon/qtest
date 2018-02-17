class ItemType < ApplicationRecord
  include Importable
  
  belongs_to :category
  has_many :items

  def category_names
    category.name.split("_")
  end

  def art_type
    case
    when category_names.any? {|name| name == "original"} then "original"
    when category_names.any? {|name| name == "limited"} then "limited"
    end
  end

  def substrates
    substrate = category_names & FieldValue.all_substrate.pluck(:name)
    substrate.join("")
  end

  def medium2
    [properties["leafing"], properties["remarque"]].reject {|m| m.blank?}.count
  end

  def format_values(name)
    case
    when name == substrates then "on #{properties[name]}"
    when name == "painting" &&  properties[name] != "painting" then "#{properties[name]} painting"
    when medium2 == 2 && name == "leafing" then "with #{properties[name]}"
    when medium2 == 2 && name == "remarque" then "and #{properties[name]}"
    when medium2 == 1 && name == "remarque" || name == "leafing" then "with #{properties[name]}"
    else properties[name]
    end
  end

  def item_description
    if properties?
      description = []
      names = category_names.map {|name| name if properties[name].present?}
      names.each do |name|
        format_values(name)
        description << format_values(name)
      end
      description.join(" ")
    end
  end
end
