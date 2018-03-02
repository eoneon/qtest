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
    if properties && properties.try(:[], "innerdiameter").present?
      [properties.try(:[], "innerdiameter")]
    elsif properties && properties.try(:[], "innerwidth").present?
      [properties.try(:[], "innerwidth"), properties.try(:[], "innerheight")].reject {|i| i.blank?}
    end
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
    elsif inner_dim_arr.count == 2
      [inner_dim_arr[0] + "\"", inner_dim_arr[-1] + "\""].join(" x ")
    end
  end

  def outer_dims
    [outer_dim_arr[0] + "\"", outer_dim_arr[-1] + "\""].join(" x ") if outer_dim_arr.present?
  end

  def plus_size
    if frame_size && frame_size > 1200
      "(#{outer_dims})"
    elsif frame_size.blank? && image_size && image_size > 1200
      "(#{inner_dims})"
    end
  end

  def format_targets
    dim_type.targets.map {|target| "(#{target})"} if dim_type
  end

  def dims_arr
    [inner_dims, outer_dims].reject {|i| i.blank?}
  end

  def format_dimensions
    m = ["Measures approx."]
    i = 0
    dims_arr.each do |dim|
      m << dim_punctuation(dim, format_targets[i])
      i =+ 1
    end
    m.join(" ")
  end

  def dim_punctuation(dim, target)
    #dim: 24" ; #target: (frame)
    if outer_dim_arr.present? && target.index(/#{Regexp.quote(dim_type.outer_target)}/)
      "#{dim} #{target},"
    elsif inner_dim_arr.present? && target.index(/#{Regexp.quote(dim_type.inner_target)}/)
      "#{dim} #{target}."
    end
  end

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def from_edition
    article = article_list.any? {|word| word == properties["edition"]} ? "an" : "a"
    ["from", article, properties["edition"], "edition"].join(" ")
  end

  def numbered
    [properties["edition"], properties["numbered"], "#{properties["number"]}/#{properties["size"]}"].join(" ")
  end

  def numbered_qty
    [properties["edition"], properties["numbered"]].join(" ")
  end

  def numbered_from
    [properties["edition"], properties["numbered"], "out of", properties["size"]].join(" ")
  end

  def not_numbered
    "This piece is not numbered."
  end

  def build_edition
    if properties
      case
      when edition_type.name == "edition" && properties["edition"].present? then [from_edition]
      when edition_type.name == "edition_numbered_number_size" && properties["numbered"].present? && properties["number"].present? && properties["size"].present? then [numbered]
      when edition_type.name == "edition_numbered" && properties["numbered"].present? && properties["number"].blank? && properties["size"].blank? then [numbered_qty]
      when edition_type.name == "edition_numbered_size" && properties["edition"].present? && properties["numbered"].present? && properties["size"].present? then [numbered_from]
      when edition_type.name == "not numbered" then [not_numbered]
      end
    end
  end

  # def image_size
  #   if item_type && dim_type.inner_target
  #     item_type && dim_type.inner_target ? properties[dim_type.category_names[0]] * properties[dim_type.category_names[1]]
  #   end
  # end

  def tagline_list
    %w(mount item edition sign cert)
  end

  def build_list
    attribute_names.map {|k| k.remove("_type_id") if k.index(/_type_id/) && public_send(k).present?}.reject {|w| w.nil?}
  end

  def build_mount
    ["Framed", "This piece comes #{mount_type.description}."] if mount_type.context == "framed"
  end

  def build_item
    if item_type && mount_type && mount_type.context == "gallery wrapped"
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

  def build_tagline
    tagline_list.map {|type| public_send("build_" + type) if build_list.include?(type)}.reject {|i| i.nil?}
  end
end
