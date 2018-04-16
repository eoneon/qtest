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
  #eg: "custom framed", "gallery wrapped", "stretched"...

  def wrapped
    properties["wrapped"] if properties["wrapped"]
  end
  #=> "stretched", "gallery wrapped"

  def gallery_wrapped
    wrapped if wrapped == "gallery wrapped"
  end

  def stretched
    wrapped if wrapped == "stretched"
  end

  def framed_args(ver)
    case
    when ver == "inv" || ver == "tag" then h = {pos: "before", occ: 0, v: mount_key, ws: 1}
    when ver == "body" then mount_clause
    end
  end

  def wrapped_args(ver)
    case
    when ver == "inv" then h = {pos: "before", occ: 0, pat: "canvas", v: mount_value, ws: 1}
    when ver == "tag" && gallery_wrapped then h = {pos: "before", occ: 0, pat: "canvas", v: mount_value, ws: 1}
    when ver == "body" && stretched then h = {pos: "before", occ: 0, pat: "canvas", v: mount_value, ws: 1}
    when ver == "body" && gallery_wrapped then mount_clause
    end
  end

  def mount_clause
    "This piece comes #{properties[mount_key]}" if mount_key == "framed" || mount_value == "gallery wrapped"
  end

  #get description args
  def typ_ver_args(ver)
    public_send(mount_key + "_" + "args", ver)
  end

  def dropdown
    properties[category.name]
  end
end
