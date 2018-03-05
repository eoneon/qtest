class Item < ApplicationRecord
  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  def properties_context
    if properties
      properties.keep_if {|k,v| v.present?}.keys
    end
  end

  def inner_dim_arr
    [properties.try(:[], "innerwidth"), properties.try(:[], "innerheight"), properties.try(:[], "innerdiameter")].reject {|i| i.blank?} if properties
  end

  def outer_dim_arr
    [properties.try(:[], "outerwidth"), properties.try(:[], "outerheight")].reject {|i| i.blank?} if properties
  end

  def image_size
    inner_dim_arr[0].to_i * inner_dim_arr[-1].to_i if inner_dim_arr.count >= 1
  end

  def frame_size
    outer_dim_arr[0].to_i * outer_dim_arr[1].to_i if outer_dim_arr.count == 2 && dim_type.outer_target == "frame"
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
      # case
      # when edition_type.category_names == ["edition"] && properties["edition"].present? then [from_edition]
      # when edition_type.category_names.count == 4 && properties["numbered"].present? && properties["number"].present? && properties["size"].present? then [numbered]
      # when edition_type.category_names.count == 2 && properties["numbered"].present? && properties["number"].blank? && properties["size"].blank? then [numbered_qty]
      # when edition_type.category_names.count == 3 && properties["edition"].present? && properties["numbered"].present? && properties["size"].present? then [numbered_from]
      # when properties["unnumbered"].present? && properties["unnumbered"] == "not numbered" then [not_numbered]
      # end
    end
  end

  def build_dim
    [plus_size, format_dimensions].reject {|i| i.blank?}
  end

  def tagline_list
    %w(mount item edition sign cert) & build_list
  end

  def description_list
    %w(item edition sign cert dim)
  end

  def build_list
    attribute_names.map {|k| k.remove("_type_id") if k.index(/_type_id/) && public_send(k).present?}.reject {|w| w.nil?}
  end

  def build_mount
    ["Framed", "This piece comes #{mount_type.description}."] if mount_type.context == "framed"
  end

  def build_item
    if item_type && plus_size
      [item_type.description.insert(item_type.plus_size_pos, plus_size)]
    elsif item_type && mount_type && mount_type.context == "gallery wrapped"
      [item_type.description.gsub(/canvas/, "#{mount_type.description} canvas")]
    elsif item_type && mount_type && mount_type.context == "stretched"
      [item_type.description, item_type.description.gsub(/canvas/, "#{mount_type.description} canvas")]
    elsif item_type
      [item_type.description]
    end
  end

  def build_sign
    sign_type.description
  end

  def build_cert
    cert_type.description
  end

  # def build_tagline
  #   tagline_list.map {|type| public_send("build_" + type) if build_list.include?(type)}.reject {|i| i.nil?}
  # end

  # def build_tagline
  #   tagline_list.map {|type| public_send("build_" + type)}
  # end

  def build_tagline
    tagline_list.map {|type| format_clauses(type)}.join(" ")
  end

  def format_clauses(type)
    if type == "item"
      if tagline_list[-1] == "item"
        "#{public_send("build_" + type)[0]}."
      elsif tagline_list[-1] != "item" && build_list.include?("edition") || build_list.include?("sign")
        "#{public_send("build_" + type)[0]},"
      #when tagline_list[-1] == "cert" && build_list.exclude?("edition") && build_list.exclude?("sign") then "#{public_send("build_" + type)},"
      else
        "#{public_send("build_" + type)[0]}"
      end
    elsif type == "edition" && build_edition
      if tagline_list[-1] == "edition"
        "#{public_send("build_" + type)[0]}."
      elsif tagline_list[-1] != "edition" && build_list.include?("sign")
        "#{public_send("build_" + type)[0]} and"
      else
        "#{public_send("build_" + type)[0]}"
      end
    elsif type == "sign" && sign_type.description
      if tagline_list[-1] == "sign"
        "#{public_send("build_" + type)[0]}."
      else
        "#{public_send("build_" + type)[0]}"
      end
    elsif type == "cert"
      "#{public_send("build_" + type)[0]}."
    else
      "#{public_send("build_" + type)}"
    end
  end

  def build_description
    description_list.map {|type| public_send("build_" + type) if build_list.include?(type)}.reject {|i| i.nil?}
  end
end
