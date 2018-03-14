class Item < ApplicationRecord
  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  def to_method(k)
    public_send(k.remove("_id"))
  end

  def to_clause(k)
    k[-8..-1] == "_type_id" ? k.remove("_type_id") : k.remove("_id")
  end

  def valid_types
    attribute_names.map {|k| validate_types(k) if k.index(/_type_id/) && public_send(k).present?}.reject {|i| i.blank?}
  end

  def validate_types(k)
    if k == "edition_type_id" || k == "dim_type_id"
      validate_properties_types(k)
    elsif to_method(k) && to_method(k).properties.present?
      to_clause(k)
    end
  end

  def validate_properties_types(k)
    to_clause(k) if to_method(k).required_fields.keep_if {|field| valid_properties_keys.include?(field)} == to_method(k).required_fields
  end

  def valid_properties_keys
    properties.keep_if {|k,v| v.present?}.keys if properties
  end

  def tagline_list
    %w(item edition sign cert) & valid_types
  end

  def description_list
    %w(item edition sign cert dim) & valid_types
  end

  ###
  def dim_set
    dim_type.dimensions.map {|d| format_dims(d)}
  end

  def format_dims(d)
    d.map {|d| format_metric(d)}
  end

  def format_metric(d)
    d == "weight" ? "#{properties[d]}lbs" : "#{properties[d]}\""
  end

  def join_dims(dim_set, delim)
    dim_set.map {|d| d.join(delim)}
  end

  def insert_targets(d)
    dims = d.zip(dim_type.formatted_targets)
    dims.map {|dims| dims.join(" ")}
  end

  def reformat_three_d(d)
    [d.take(dim_type.weight_index), d.drop(dim_type.weight_index)]
    #dims = d.take(dim_type.weight_index)
    #weight = d.drop(dim_type.weight_index)
  end

  #dim_description
  def branching_dim
    if dim_type.two_d_targets.present?
      d = join_dims(dim_set, " x ")
      d = insert_targets(d)
    elsif dim_type.three_d_targets.present?
      d = insert_targets(dim_set)
      d = reformat_three_d(d)
      #=> [["5\" (width)", "6\" (height)"], ["7lbs (weight)"]]
      d = join_dims(d, " x ")
      #=> ["5\" (width) x 6\" (height)", "7lbs (weight)"]
    end
    delim = dim_type.three_d_targets ? "; " : ", "
    "Measures approx. #{d.join(delim)}."
    #join_dims(d, delim) #wont work here because of different levels?
  end

  ##

  def inner_dim_arr
    dim_type.inner_dims.map {|d| properties[d]} if dim_type && dim_type.inner_dims
    #[properties.try(:[], "innerwidth"), properties.try(:[], "innerheight"), properties.try(:[], "innerdiameter")].reject {|i| i.blank?} if properties
  end

  def outer_dim_arr
    dim_type.outer_dims.map {|d| properties[d]} if dim_type && dim_type.outer_dims
    #[properties.try(:[], "outerwidth"), properties.try(:[], "outerheight")].reject {|i| i.blank?} if properties
  end

  def image_size
    inner_dim_arr[0].to_i * inner_dim_arr[-1].to_i if inner_dim_arr.present? && inner_dim_arr.count >= 1
  end

  def frame_size
    outer_dim_arr[0].to_i * outer_dim_arr[1].to_i if outer_dim_arr.present? && outer_dim_arr.count == 2 && dim_type.outer_target == "frame"
  end

  def plus_size
    if frame_size && frame_size > 1200
      "(#{join_dims(dim_set, " x ")[-1]})"
    elsif frame_size.blank? && image_size && image_size > 1200
      "(#{join_dims(dim_set, " x ")[0]})"
    end
  end

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def from_an_edition
    article = article_list.any? {|word| word == properties["edition"]} ? "an" : "a"
    ["from", article, properties["edition"], "edition"].join(" ") #if properties["edition"].present?
  end

  def numbered
    [properties["edition"], properties["numbered"], "#{properties["number"]}/#{properties["size"]}"].join(" ") #if properties["numbered"].present? && properties["number"].present? && properties["size"].present?
  end

  def numbered_qty
    [properties["edition"], properties["numbered"]].join(" ") #if properties["numbered"].present? && properties["number"].blank? && properties["size"].blank?
  end

  def numbered_from_edition_size
    [properties["edition"], properties["numbered"], "out of", properties["size"]].join(" ") #if properties["edition"].present? && properties["numbered"].present? && properties["size"].present?
  end

  def not_numbered
    "This piece is not numbered." #if properties["unnumbered"].present? && properties["unnumbered"] == "not numbered"
  end

  def substrate
    item_type.substrates if item_type
  end

  ##replace with refactored: :format_item(description), :insert_mounting(type, description), :insert_plus_size(description), :insert_punctuation(type, description)
  #kill: or refactor to replace hardcoded version below
  def substrate_pos(build)
    mount_type.context == "framed" ? 0 : build.index(/#{Regexp.quote(substrate_kind)}/) + substrate_kind.length
  end

  def substrate_kind
    item_type.substrates if item_type
  end

  #kill
  def frame
    if mount_type.present?
      "framed" if mount_type.context == "framed"
    end
  end

  #kill
  def wrapped
    if mount_type.present?
      mount_type.tagline_mounting if mount_type.context == "wrapped"
    end
  end

  #kill
  def frame_pos(description)
    pos = 0
    description[0].insert(pos, "#{frame} ")
  end

  #kill
  def wrapped_pos(description)
    pos = substrate_pos(description[0])
    description[0].insert(pos, "#{wrapped} ")
  end

  #kill
  def punctuate_item
    tagline_list[-1] == "item" ? "." : ","
  end

  #kill
  def punctuate_edition
    if tagline_list[-1] == "edition"
      "."
    elsif sign_type
      " and"
    end
  end

  #kill & replace with :insert_punctuation
  def plus_size_pos(description)
    if plus_size
      pos = description[0].index(/#{Regexp.quote(substrate)}/) + substrate.length
      description[0].insert(pos, " #{plus_size}")
    end
  end

  #kill & replace with :insert_punctuation
  def punctuate_item_pos(description)
    pos = description[0].length
    description[0].insert(pos, punctuate_item)
    #description[0].insert(description[0].length, punctuate_item)
  end

  #kill & replace with :insert_punctuation
  def punctuate_edition_pos(description)
    pos = description[0].length
    description[0].insert(pos, punctuate_edition)
  end

  #kill & replace with :insert_punctuation
  def punctuate_cert_pos(description)
    pos = description[0].length
    description[0].insert(pos, punctuate_cert)
  end

  #kill & replace with :insert_punctuation
  def punctuate_sign
    if tagline_list[-1] == "sign"
      "."
    end
  end

  #kill & replace with :insert_punctuation
  def punctuate_cert
    "."
  end

  #kill & replace with :insert_punctuation
  def punctuate_sign_pos(description)
    pos = description[0].length
    description[0].insert(pos, punctuate_sign)
  end

  #refactor: already handling with tagline_mounting
  def build_mount
    mount_type.description
    #[frame, "This piece comes #{mount_type.description}."] if mount_type.mounting == "framed"  || mount_type.mounting == "wrapped"
  end

  #test
  # def dogs
  #   "colored"
  # end

  # def remove_values
  #   ["sold", "gold", /#{Regexp.quote(dogs)}/ ]
  #   #["sold", "gold", dogs]
  # end

  def build_item
    [item_type.description]
  end

  def build_edition
    if properties
      [public_send(edition_type.dropdown.split(" ").join("_"))]
    end
  end

  def build_sign
    sign_type.description
  end

  def build_cert
    cert_type.description
  end

  #refactor: already handling plus_size
  def build_dim
    [plus_size, branching_dim].reject {|i| i.blank?}
  end

  #start here
  def build_tagline
    tagline_list.map {|type| format_build(public_send("build_" + type)[0], type)}.compact.join(" ")
  end

  #new
  def format_build(build, type)
    build = format_item(build) if type == "item"
    insert_punctuation(type, build)
  end

  #new
  def format_item(build)
    ["mounting", "plus_size"].each do |m|
      build = insert_element(build, m) if public_send(m)
    end
    #build
    build.remove(*remove_values)
  end

  #new
  def insert_element(build, m)
    build.insert(substrate_pos(build), " #{public_send(m)} ").strip
  end

  def mounting
    mount_type.tagline_mounting if mount_type.present?
  end

  #not sure how to make this dynamic
  def remove_values
    arr = ["giclee", "stretched"]
    arr + [/#{Regexp.quote(substrate_value)}/] if substrate_value
  end

  def substrate_value
    if substrate_kind == "paper"
      "on #{item_type.properties[substrate_kind]}"
    end
  end

  #new
  def insert_punctuation(type, build)
    case
    when type == tagline_list[-1] then punct = "."
    when type == "item" && tagline_list.any? {|w| ["edition", "sign"].include?(w)} then punct = ", "
    when type == "edition" && tagline_list.include?("sign") then punct = " and"
    end
    punct ? build.insert(build.length, punct) : build
  end

  #kill
  def format_type(type, description)
    if type && description && description[0].present?
      public_send("format_" + type, [description])
    end
  end

  ##refactored


  # def format_item(description)
  #   description = description[0]
  #   [["frame_pos", frame], ["wrapped_pos", wrapped], ["plus_size_pos", plus_size], ["punctuate_item_pos", punctuate_item]].each do |i|
  #     description = public_send(i[0], [description]) if i[-1]
  #   end
  #   description
  # end

  #kill
  def format_edition(description)
    description = description[0]
    [["punctuate_edition_pos", punctuate_edition]].each do |i|
      description = public_send(i[0], [description]) if i[-1]
    end
    description
  end

  #kill
  def format_sign(description)
    description = description[0]
    [["punctuate_sign_pos", punctuate_sign]].each do |i|
      description = public_send(i[0], [description]) if i[-1]
    end
    description
  end

  #kill
  def format_cert(description)
    description = description[0]
    [["punctuate_cert_pos", punctuate_cert]].each do |i|
      description = public_send(i[0], [description]) if i[-1]
    end
    description
  end

  def build_description
    description_list.map {|type| public_send("build_" + type) if valid_types.include?(type)}.reject {|i| i.nil?}
  end
end
