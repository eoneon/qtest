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

  def frame_args(ver)
    case
    when ver == "inv" || ver == "tag" then h = {pos: "before", v: mount_key}
    when ver == "body" then mount_clause
    end
  end

  def wrapped_args(ver)
    case
    when ver == "inv" then h = {pos: "before", pat: "canvas", v: mount_value, ws: 1}
    when ver == "tag" && gallery_wrapped then h = {pos: "before", pat: "canvas", v: mount_value}
    when ver == "body" && stretched then h = {pos: "before", pat: "canvas", v: mount_value}
    when ver == "body" && gallery_wrapped then mount_clause
    end
  end

  def mount_clause
    "This piece comes #{properties[mount_key]}." if mount_key == "framed" || mount_value == "gallery wrapped"
  end

  #get description args
  def typ_ver_args(ver)
    public_send(mount_key + "_" + "args", ver)
  end

  def dropdown
    properties[category.name]
  end

  #########

  #kill
  def mounting
    category_names[0] if category_names && category_names[0] != "flat"
  end
  #=> "framed", "wrapped"

  #kill
  def framed
    mounting if mounting == "framed"
  end
  #=> framed

  #kill
  def descrp(ver)
    public_send(mount_key + "_" + "descrp", ver)
  end

  #kill
  def inv
    case
    when mounting == framed then h = {pos: "before", v: framed}
    when wrapped then h = {pos: "before", pat: "canvas", v: wrapped}
    end
  end

  #kill
  def tag
    case mounting
    when framed then h = {pos: "before", v: framed}
    when gallery_wrapped then h = {pos: "before", pat: "canvas", v: wrapped}
    end
  end

  #kill
  def body
    case
    when mounting == framed || mounting == gallery_wrapped then description_mounting
    when stretched then h = {pos: "before", pat: "canvas", v: wrapped}
    end
  end

  #kill
  def context
    mounting if ["framed", "wrapped"].include?(mounting)
  end

  #kill
  def tagline_mounting
    if context == "framed"
      context
    elsif context == "wrapped"
      properties[context]
    end
  end

  #kill
  def description_mounting
    if tagline_mounting == "framed" || tagline_mounting == "gallery wrapped"
      "This piece comes #{properties[context]}."
    end
  end

  #kill
  def description
    [description_mounting]
  end

  #kill
  def stub
    case
    when mounting == "framed" then ["framed", "This piece comes #{properties[context]}."]
    when mounting == "wrapped" then [properties[context]]
    end
  end
end
