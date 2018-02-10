class ItemType < ApplicationRecord
  include Importable

  belongs_to :category

  def category_names
    category.name.split("_")
  end

  def substrates
    substrate = category_names & FieldValue.all_substrate.pluck(:name) #["canvas", "paper", "panel", "sericel"]
    substrate.join("")
  end

  def format_values(name)
    case
    when name == substrates then "on #{properties[name]}"
    when name == "painting" &&  properties[name] != "painting" then "#{properties[name]} painting"
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
