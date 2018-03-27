class ItemType < ApplicationRecord
  include Importable
  include SharedMethods

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

  # def category_names
  #   category.name.split("_")
  # end

  def self.flat_items
    canvas_items + paper_items + panel_items + sericel_items
  end

  def self.print_items
    printed_items + animation_items + photo_items + etching_items
  end

  #new: keep properties keys if value present
  def valid_keys
    properties.keep_if {|k,v| v.present?}.keys if properties
  end
  #=>["mixed", "panel", "original"]

  #reorder keys and set properties values
  def valid_keys_ordered
    category_names.map {|k| k if valid_keys.include?(k)}.compact
  end
  #=> ["original", "monprint", "panel"]

  def art_type
    case
    when category_names.any? {|name| name == "original"} then "original"
    when category_names.any? {|name| name == "limited"} then "limited"
    end
  end

  def substrates
    %w(canvas paper sericel panel)
  end

  def format_values(k)
    case
    when substrates.include?(k) then "on #{properties[k]}"
    when k == "painting" && properties[k] != "painting" then "#{properties[k]} painting"
    when k == "leafing" then "with #{properties[k]}"
    when k == "remarque" && category_names.include?("leafing") then "and #{properties[k]}"
    when k == "remarque" && category_names.exclude?("leafing") then "with #{properties[k]}"
    else properties[k]
    end
  end

  def properties_loop
    medium = []
    valid_keys_ordered.each do |k|
      medium << format_values(k)
    end
    [medium.join(" ")]
  end

  def description
    properties_loop if properties?
  end

  def dropdown
    description[0]
  end
end
