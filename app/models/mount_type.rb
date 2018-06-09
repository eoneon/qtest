class MountType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def valid_keys
    properties.keep_if {|k,v| k if v.present?} if properties.present?
  end

  def key_value(k)
    properties[k] if valid_keys.include?(k)
  end

  def key_value_eql?(k, v)
    valid_keys.include?(k) && properties[k] == v
  end

  def mount_key
    category_names[0] if category_names && category_names[0] != "flat"
  end
  #=> "framed", "wrapped"

  def mount_value
    properties[mount_key]
  end
  #=> "custom framed", "gallery wrapped", "stretched"...

  def mount_key_eql?(v)
    mount_key == v
  end

  def mount_value_eql?(v)
    mount_value == v
  end

  def mount_clause
    "This piece comes #{mount_value}."
  end

  #used on item.rb
  def framed?
    mount_key == "framed"
  end

  #used on item.rb
  def stretched?
    mount_value == "stretched"
  end

  def gallery_wrapped?
    mount_value == "gallery wrapped"
  end

  def wrapped?
    stretched? || gallery_wrapped?
  end

  def mount_context(ver)
    #ver == "tag" && gallery_wrapped? || ver == "inv" && mount_key == "wrapped" || stretched? && ver == "body" ? "insert_mount" : "push_mount"
    ver == "tag" && mount_value_eql?("gallery wrapped") || ver == "inv" && mount_key_eql?("wrapped") || ver == "body" && mount_value_eql?("stretched") ? "insert_mount" : "push_mount"
  end

  def tag_wrapped
    mount_value if mount_value == "gallery wrapped"
  end

  def inv_wrapped
    mount_value if mount_key == "wrapped"
  end

  def body_wrapped
    mount_value_eql?("stretched") ? mount_value : mount_clause
  end

  def tag_framed
    mount_key
  end

  def inv_framed
    tag_framed
  end

  def body_framed
    mount_clause
  end

  def typ_ver_args(ver)
    public_send(ver + "_" + mount_key) unless mount_key == "flat"
  end

  def dropdown
    properties[category.name]
  end
end
