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

  ####
  def valid_keys
    properties.keep_if {|k,v| v.present?}.keys if properties
  end

  def valid_key?(k)
    valid_keys && valid_keys.include?(k)
  end

  def art_type
    [original, limited].join("")
  end

  def value_eql?(k, v)
    valid_key?(k) && properties[k] = v
  end

  def split_value(k)
    valid_key?(k) && properties[k].split(" ")
  end

  def pat_match?(k, v)
    valid_key?(k) && split_value(k).include?(v)
  end
  ####

  ###refactor or use art_keys

  def embellished?
    valid_keys.include?("embellish")
  end

  def artwork_keys
    %w(original limited)
  end

  def art_type_keys
    valid_keys & %w(original limited print sculpturetype book sports)
  end

  def medium_keys
    %w(painting print mixed sketch etching photo animation sculpturemedium)
  end

  def substrate_keys
    %w(canvas paper sericel panel)
  end
  ##
  def substrate_key
    valid_keys & substrate_keys
  end

  def medium_key
    k = valid_keys & medium_keys
    k[0]
  end
  ##
  def original
    "original" if valid_keys.include?("original")
  end

  def limited
    "limited" if valid_keys.include?("limited")
  end

  #ordered_kv_pairs
  def ordered_keys
    category_names.map {|k| k if valid_keys.include?(k)}.compact
  end
  #=> ["original", "monprint", "panel"]
  def medium
    if pat_match?("print", "silkscreen")
      "serigraph"
    elsif pat_match?("print", "lithograph")
      "lithograph"
    #elsif valid_key?("sketch") && arr_match?(split_value("sketch"), ["pen", "ink"])
    elsif valid_key?(medium_key) && arr_match?(split_value(medium_key), ["pen", "ink"])
      "pen and ink"
    elsif valid_key?("sketch") && pat_match?("sketch", "pencil")
      "pencil"
    elsif valid_key?("painting") &&  ["watercolor", "gauche", "sumi ink"].include?(properties["painting"])
      "watercolor"
    elsif valid_key?("painting") && ["oil", "acrylic", "pastel", "monoprint"].include?(properties["painting"])
      properties["painting"]
    # elsif value_eql?("mixed", "monoprint")
    #   "monoprint"
    elsif valid_key?("painting") && arr_match?(split_value("painting"), ["mixed", " and "]) #! value_eql?("mixed", "monoprint")
      "mixed media"
    elsif valid_key?("print") && arr_match?(split_value("print"), ["mixed", " and "])
      "mixed media"
    elsif valid_key?("painting") && value_eql?("painting", "painting")
      "unknoun"
    elsif pat_match?("print", "poster")
      "poster"
    else
      properties[medium_key]
    end
  end

  def csv_art_type
    if art_type_keys.include?("limited") && art_type_keys.exclude?("sculpturetype")
      "limited edition"
    elsif pat_match?("print", "poster")
      "poster"
    elsif art_type_keys.include?("print") && art_type_keys.exclude?("limited")
      "print"
    elsif art_type_keys.include?("sculpturetype")
      "sculpture/glass"
    else
      art_type_keys[0]
    end
  end

  def csv_art_category
    if valid_key?("print")
      "limited edition"
    elsif valid_key?("original")
      "original painting"
    elsif value_eql?("handmade", "hand blown glass")
      "hand blown glass"
    elsif art_type_keys.include?("sculpturetype") && ! value_eql?("handmade", "hand blown glass")
      "sculpture"
    else
      art_type_keys[0]
    end
  end

  def format_panel
    arr_match?(split_value("panel"), %(metal aluminum)) ? "metal" : "board"
  end

  def flat_substrate
    if %w(paper canvas sericel).include?(substrate_key[0])
      substrate_key[0]
    elsif substrate_key[0] == "panel"
      format_panel
    end
  end

  def csv_substrate
    if %w(paper canvas sericel).include?(substrate_key)
      substrate_key
    elsif substrate_key == "panel"
      format_panel("panel")
    elsif substrate_key == "sculpturemedia"
      format_sculpture(substrate_key)
    end
  end

  def csv_material
    k = %w(paper canvas sericel panel sculpturemedia) & valid_keys
    if %w(paper canvas sericel).include?(k[0])
      k[0]
    elsif k[0] == "panel"
      format_panel(k[0])
    elsif k[0] == "sculpturemedia"
      format_sculpture(k[0])
    end
  end

  def tag_keys
    ordered_keys.delete_if {|k| (k == "paper" && properties[k] != "archival grade photography paper") || (properties[k] == "giclee" && properties["limited"].present?) }
  end

  def ver_keys(ver)
    ver == "tag" ? tag_keys : ordered_keys
  end

  def frame_ref
    properties[ordered_keys[0]]
  end

  def dim_ref_key(ver)
    keys = [substrate_key] + [medium_key] + artwork_keys
    keys.map {|k| return k if ver_keys(ver).include?(k)}
  end

  def xl_dim_ref
    #properties[dim_ref_key("tag")]
    ver_keys("tag").include?("painting")  ? "painting" : properties[dim_ref_key("tag")]
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
