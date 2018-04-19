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

  def self.flat_items
    canvas_items + paper_items + panel_items + sericel_items
  end

  def self.print_items
    printed_items + animation_items + photo_items + etching_items
  end

  #was using for hiding/showing edition on items: refactor dependent on js
  def art_type
    case
    when category_names.any? {|name| name == "original"} then "original"
    when category_names.any? {|name| name == "limited"} then "limited"
    end
  end

  #new: keep properties keys if value present
  def valid_properties
    properties.keep_if {|k,v| v.present?}.keys if properties
  end
  #=>["mixed", "panel", "original"]

  #reorder keys and set properties values
  def valid_properties_ordered
    category_names.map {|k| k if valid_properties.include?(k)}.compact
  end
  #=> ["original", "monprint", "panel"]

  def substrates
    %w(canvas paper sericel panel)
  end

  def media
    %w(painting print mixed sketch etching photo animation)
  end

  def property_key(property_kind)
    arr = category_names & property_kind
    arr[0]
  end

  def media_key
    property_key(media)
  end

  def substrate_key
    property_key(substrates)
  end

  def property_kind_pos(property_key)
    idx_after_i(category_names, property_key, 0)
  end

  def substrate_pos
    property_kind_pos(substrate_key)
  end

  # def xl_dim_pos
  #   if substrate_key != "paper"
  #     substrate_pos - 1
  #   elsif substrate_key == "paper" && properties[media_key] != "giclee"
  #     substrate_pos - 2
  #   elsif substrate_key == "paper" && properties[media_key] == "giclee"
  #     substrate_pos - 3
  #   end
  # end

  def xl_dim_pos
    case
    when substrate_key != "paper" then substrate_pos - 1
    when substrate_key == "paper" && properties[media_key] != "giclee" then substrate_pos - 2
    when substrate_key == "paper" && properties[media_key] == "giclee" then substrate_pos - 3
    end
  end

  def xl_dim_ref
    properties[category_names[xl_dim_pos]]
  end

  def substrate_args(k, ver)
   ver == "tag" && k == "paper" ? return : "on #{properties[k]}"
  end

  def print_args(k, ver)
   ver == "tag" && properties[k] == "giclee" ? return : properties[k]
  end

  def format_args(k, ver)
    case
    when substrates.include?(k) then substrate_args(k, ver)
    when k == "print" then print_args(k, ver)
    when k == "painting" && properties[k] != "painting" then "#{properties[k]} painting"
    when k == "leafing" then "with #{properties[k]}"
    when k == "remarque" && category_names.include?("leafing") then "and #{properties[k]}"
    when k == "remarque" && category_names.exclude?("leafing") then "with #{properties[k]}"
    else properties[k]
    end
  end

  def args_loop(ver)
    medium = []
    valid_properties_ordered.each do |k| #k: property/category_name[i]
      medium << format_args(k, ver)
    end
    medium.join(" ")
  end

  def typ_ver_args(ver)
    args_loop(ver) if properties?
  end

  def description
    args_loop("tag") if properties?
  end

  def dropdown
    description
  end
end
