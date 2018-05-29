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

  # def self.flat_items
  #   canvas_items + paper_items + panel_items + sericel_items
  # end

  # def self.print_items
  #   printed_items + animation_items + photo_items + etching_items
  # end

  #was using for hiding/showing edition on items: refactor dependent on js


  def art_type
    [original, limited].join("")
  end

  def artwork_keys
    %w(original limited)
  end

  def medium_keys
    %w(painting print mixed sketch etching photo animation)
  end

  def substrate_keys
    %w(canvas paper sericel panel)
  end

  def original
    "original" if existing_kv_pairs.include?("original")
  end

  def limited
    "limited" if existing_kv_pairs.include?("limited")
  end

  #new: keep properties keys if value present
  def existing_kv_pairs
    properties.keep_if {|k,v| v.present?}.keys if properties
  end
  #=>["mixed", "panel", "original"]

  #ordered_kv_pairs
  def ordered_keys
    category_names.map {|k| k if existing_kv_pairs.include?(k)}.compact
  end
  #=> ["original", "monprint", "panel"]

  def tag_keys
    ordered_keys.delete_if {|k| k == "paper" || properties[k] == "giclee" }
  end

  def ver_keys(ver)
    ver == "tag" ? tag_keys : ordered_keys
  end

  #filter key-type (substrate_list, media_list) if exists per valid_keys
  # def sub_type_key(key_group)
  #   arr = existing_kv_pairs & key_group
  #   arr[0]
  # end

  #kill: sub_type_key covers this, just pass in argument
  # def media_key
  #   sub_type_key(media)
  # end

  #kill
  # def substrate_key
  #   sub_type_key(substrates)
  # end
  #
  # def sub_type_pos(sub_type_key)
  #   idx_after_i(ordered_keys, sub_type_key, 0)
  # end
  #
  # def substrate_pos
  #   sub_type_pos(substrate_key)
  # end

  def frame_ref
    properties[ordered_keys[0]]
  end

  def dim_ref_key(ver)
    keys = substrate_keys + medium_keys + artwork_keys
    keys.map {|k| return k if ver_keys(ver).include?(k)}
  end

  # def xl_dim_pos
  #   case
  #   when substrate_key != "paper" then substrate_pos - 1
  #   when substrate_key == "paper" && properties[media_key] != "giclee" then substrate_pos - 2
  #   when substrate_key == "paper" && properties[media_key] == "giclee" then substrate_pos - 3
  #   end
  # end

  # def xl_dim_ref
  #   properties[category_names[xl_dim_pos]]
  # end

  def xl_dim_ref
    properties[dim_ref_key("tag")]
  end

  def artist_ref
    properties[ordered_keys[-1]]
  end

  def format_painting(k)
    properties[k] == "painting" ? properties[k] : "#{properties[k]} painting"
  end

  def format_leafing(k)
    "with #{properties[k]}"
  end

  def format_remarque(k)
    ordered_keys.include?("leafing") ? "and #{properties[k]}" : "with #{properties[k]}"
  end

  def format_arg(k)
    case
    when %w(painting leafing remarque).include?(k) then public_send("format_" + k, k)
    when substrate_keys.include?(k) then "on #{properties[k]}"
    else properties[k]
    end
  end

  def args_loop(ver)
    medium = []
    ver_keys(ver).each do |k|
      medium << format_arg(k)
    end
    medium.join(" ")
  end

  def typ_ver_args(ver)
    args_loop(ver) if properties?
  end

  def description
    args_loop("inv") if properties?
  end

  def dropdown
    description
  end
end
