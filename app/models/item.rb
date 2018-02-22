class Item < ApplicationRecord
  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def edition_context

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
    if mount_type.context == "gallery wrapped"
      [item_type.description.gsub(/canvas/, "#{mount_type.description} canvas")]
    elsif mount_type.context == "stretched"
      [item_type.description, item_type.description.gsub(/canvas/, "#{mount_type.description} canvas")]
    else
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
