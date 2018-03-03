class ItemType < ApplicationRecord
  include Importable

  belongs_to :category
  has_many :items

  #scope :paper_items, -> {where(category: Category.paper_subsrtate)}
  #scope :canvas_items, -> {where(category: Category.canvas_subsrtate)}
  #scope :orignal_items, -> {where("properties -> original = :value", value: 'original')}
  scope :original_items, -> {where("properties ? :key", key: "original")}
  scope :printed_items, -> {where("properties ? :key", key: "print")}
  scope :animation_items, -> {where("properties ? :key", key: "animation")}
  scope :photo_items, -> {where("properties ? :key", key: "photo")}
  scope :etching_items, -> {where("properties ? :key", key: "etching")}
  scope :sculpture_items, -> {where("properties ? :key", key: "sculpturetype")}
  scope :book_items, -> {where("properties ? :key", key: "booktype")}
  scope :sport_items, -> {where("properties ? :key", key: "sportitem")}
  scope :canvas_items, -> {where("properties ? :key", key: "canvas")}
  scope :paper_items, -> {where("properties ? :key", key: "paper")}
  scope :panel_items, -> {where("properties ? :key", key: "panel")}
  scope :sericel_items, -> {where("properties ? :key", key: "sericel")}
  #scope :flat_items, -> {where("properties ? :key OR properties ? :key OR properties ? :key OR properties ? :key OR properties ? :key", key: "paper", key: "canvas", key: "panel", key: "sericel")}
  #scope :flat_items, -> {where_any_of("properties ? :key OR properties ? :key", key: "paper", key: "canvas")}
  #scope :flat_items, -> {canvas_items.or.paper_items}

  def category_names
    category.name.split("_")
  end

  def self.flat_items
    canvas_items + paper_items + panel_items + sericel_items
  end

  def self.print_items
    printed_items + animation_items + photo_items + etching_items
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

  # def plus_size_pos
  #   description.index(/#{Regexp.quote(properties[substrates])}/) if properties && properties[substrates] && description
  # end

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

  def description
    if properties?
      medium = []
      names = category_names.map {|name| name if properties[name].present?}.reject {|i| i.nil?}
      names.each do |name|
        format_values(name)
        medium << format_values(name)
      end
      medium.join(" ")
      #m.insert(plus_size_pos, "dog")
    end
  end

  def plus_size_pos
    if properties && properties[substrates] && description
      description.index(/#{Regexp.quote(properties[substrates])}/) + properties[substrates].length
      #description.insert(pos, " dog")
    end
  end

  def dropdown
    description
  end
end
