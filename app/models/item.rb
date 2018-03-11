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
    dim_set = insert_targets(d).take(dim_type.weight_index)
    dim_set = join_dims(dim_set).concat(weight)
    dims.map {|dims| dims.join(" ")}
  end

  def dim_branch
    if dim_type.two_d_targets.present?
      d = join_dims(dim_set, " x ")
      d = insert_targets(d)
      #["12\" x 12\" (frame)", "22\" x 22\" (image)"]
      #d = join_dims(dim_set, " ")
          #=> [["12\" x 12\" (image)"], ["24\" x 24\" (frame)"]]
    elsif dim_type.three_d_targets.present?
      dim_type.three_d_targets
      #dim_set
      #d = insert_targets(dim_set)

          #=> [["5/", (width)"], ["7/", (height)"], ["3lbs, (weight)"]]
      #d = join_dims(dim_set, " ")
          #=> [["5/" (width)"], ["7/" (height)"], ["3lbs (weight)"]]
      #d = reformat_three_d(d)
          #=> [["5/" (width)", "7/" (height)"], ["3lbs (weight)"]]
      #d = join_dims(d, " x ")
          #=> [["5/" (width)" x "7/" (height)"], ["3lbs (weight)"]]
    end
    #delim = dim_type.three_d_targets ? "; " : ", "
    #d.join(delim)

    #join_dims(d, delim)
  end

  ##

  def inner_dim_arr
    [properties.try(:[], "innerwidth"), properties.try(:[], "innerheight"), properties.try(:[], "innerdiameter")].reject {|i| i.blank?} if properties
  end

  def outer_dim_arr
    [properties.try(:[], "outerwidth"), properties.try(:[], "outerheight")].reject {|i| i.blank?} if properties
  end

  def image_size
    inner_dim_arr[0].to_i * inner_dim_arr[-1].to_i if inner_dim_arr.present? && inner_dim_arr.count >= 1
  end

  def frame_size
    outer_dim_arr[0].to_i * outer_dim_arr[1].to_i if outer_dim_arr.present? && outer_dim_arr.count == 2 && dim_type.outer_target == "frame"
  end

  def inner_dims
    if properties.try(:[], "innerdiameter").present?
      inner_dim_arr[0] + "\""
    elsif inner_dim_arr && inner_dim_arr.count == 2
      [inner_dim_arr[0] + "\"", inner_dim_arr[-1] + "\""].join(" x ")
    end
  end

  def outer_dims
    [outer_dim_arr[0] + "\"", outer_dim_arr[-1] + "\""].join(" x ") if outer_dim_arr.present?
  end

  def three_d_dims
    #dim_type.three_d_targets.map {|target| properties[target] + "\"" if properties[target].present? && }.reject {|i| i.blank?} if dim_type.three_d_targets
    if dim_type && dim_type.three_d_targets
      dims = []
      dim_type.three_d_targets.each do |target|
        if target == "weight"
          dims << properties[target] + "lbs"
        else
          dims << properties[target] + "\""
        end
      end
    end
    dims
  end

  def plus_size
    if frame_size && frame_size > 1200
      " (#{outer_dims})"
    elsif frame_size.blank? && image_size && image_size > 1200
      " (#{inner_dims})"
    end
  end

  def format_targets
    dim_type.targets.map {|target| "(#{target})"} if dim_type
  end

  def colon_target
    format_targets[-2] if properties["weight"].present?
  end

  def dims_arr
    if inner_dims || outer_dims
      [outer_dims, inner_dims].reject {|i| i.blank?}
    elsif three_d_dims
      three_d_dims.reject {|i| i.blank?}
    end
  end

  def format_dimensions
    if dims_arr.present?
      m = ["Measures approx."]
      i = 0
      dims_arr.each do |dim|
        m << dim_punctuation(dim, format_targets[i])
        i += 1
      end
      m.join(" ")
    end
  end

  def dim_punctuation(dim, target)
    #dim: 24" ; #target: (frame)
    if outer_dim_arr.present? && target.index(/#{Regexp.quote(dim_type.outer_target)}/)
      "#{dim} #{target},"
    elsif inner_dim_arr.present? && target.index(/#{Regexp.quote(dim_type.inner_target)}/)
      "#{dim} #{target}."
    elsif three_d_dims.present? && target != format_targets[-1] && target != colon_target
      "#{dim} #{target} x"
    elsif three_d_dims.present? && target == colon_target
      "#{dim} #{target};"
    elsif three_d_dims.present? && target == format_targets[-1]
      "#{dim} #{target}."
    end
  end

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def from_an_edition
    article = article_list.any? {|word| word == properties["edition"]} ? "an" : "a"
    ["from", article, properties["edition"], "edition"].join(" ") if properties["edition"].present?
  end

  def numbered
    [properties["edition"], properties["numbered"], "#{properties["number"]}/#{properties["size"]}"].join(" ") if properties["numbered"].present? && properties["number"].present? && properties["size"].present?
  end

  def numbered_qty
    [properties["edition"], properties["numbered"]].join(" ") if properties["numbered"].present? && properties["number"].blank? && properties["size"].blank?
  end

  def numbered_from_edition_size
    [properties["edition"], properties["numbered"], "out of", properties["size"]].join(" ") if properties["edition"].present? && properties["numbered"].present? && properties["size"].present?
  end

  def not_numbered
    "This piece is not numbered." if properties["unnumbered"].present? && properties["unnumbered"] == "not numbered"
  end

  def build_edition
    if properties
      [public_send(edition_type.dropdown.split(" ").join("_"))]
    end
  end

  def build_dim
    [plus_size, format_dimensions].reject {|i| i.blank?}
  end

  def substrate
    item_type.substrates if item_type
  end

  def substrate_pos(description)
    description.index(/#{Regexp.quote(substrate)}/)
  end

  def frame
    if mount_type.present?
      "framed" if mount_type.mounting == "framed"
    end
  end

  def frame_pos(description)
    pos = 0
    description[0].insert(pos, "#{frame} ")
  end

  def wrapped
    if mount_type.present?
      mount_type.context if mount_type.mounting == "wrapped"
    end
  end

  def wrapped_pos(description)
    pos = substrate_pos(description[0])
    description[0].insert(pos, "#{wrapped} ")
  end

  def punctuate_item
    tagline_list[-1] == "item" ? "." : ","
  end

  def punctuate_edition
    if tagline_list[-1] == "edition"
      "."
    elsif sign_type
      " and"
    end
  end

  def plus_size_pos(description)
    if plus_size
      pos = description[0].index(/#{Regexp.quote(substrate)}/) + substrate.length
      description[0].insert(pos, " #{plus_size}")
    end
  end

  def punctuate_item_pos(description)
    pos = description[0].length
    description[0].insert(pos, punctuate_item)
  end

  def punctuate_edition_pos(description)
    pos = description[0].length
    description[0].insert(pos, punctuate_edition)
  end

  def punctuate_cert_pos(description)
    pos = description[0].length
    description[0].insert(pos, punctuate_cert)
  end

  def punctuate_sign
    if tagline_list[-1] == "sign"
      "."
    end
  end

  def punctuate_cert
    "."
  end

  def punctuate_sign_pos(description)
    pos = description[0].length
    description[0].insert(pos, punctuate_sign)
  end



  def build_mount
    [frame, "This piece comes #{mount_type.description}."] if mount_type.mounting == "framed"  || mount_type.mounting == "wrapped"
  end

  def build_item
    [item_type.description]
  end

  def build_sign
    sign_type.description
  end

  def build_cert
    cert_type.description
  end

  def build_tagline
    tagline_list.map {|type| format_type(type, public_send("build_" + type)[0])}.reject {|i| i.blank?}.join(" ")
  end

  def format_type(type, description)
    if description && description[0].present?
      public_send("format_" + type, [description])
    end
  end

  def format_item(description)
    description = description[0]
    [["frame_pos", frame], ["wrapped_pos", wrapped], ["plus_size_pos", plus_size], ["punctuate_item_pos", punctuate_item]].each do |i|
      description = public_send(i[0], [description]) if i[-1]
    end
    description
  end

  def format_edition(description)
    description = description[0]
    [["punctuate_edition_pos", punctuate_edition]].each do |i|
      description = public_send(i[0], [description]) if i[-1]
    end
    description
  end

  def format_sign(description)
    description = description[0]
    [["punctuate_sign_pos", punctuate_sign]].each do |i|
      description = public_send(i[0], [description]) if i[-1]
    end
    description
  end

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
