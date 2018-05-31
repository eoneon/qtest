class MountType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def mount_key
    category_names[0] if category_names && category_names[0] != "flat"
  end
  #=> "framed", "wrapped"

  def mount_value
    properties[mount_key]
  end
  #=> "custom framed", "gallery wrapped", "stretched"...

  def mount_clause
    "This piece comes #{mount_value}"
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
    ver == "tag" && gallery_wrapped? || ver == "inv" && mount_key == "wrapped" || stretched? && ver == "body" ? "insert_mount" : "push_mount"
  end

  def tag_wrapped
    mount_value if mount_value == "gallery wrapped"
  end

  def inv_wrapped
    mount_value if mount_key == "wrapped"
  end

  def body_wrapped
    stretched? ? mount_value : mount_clause
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
