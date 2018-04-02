class MountType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def h_args
    h = {pos: "before", pat:"canvas", v: " #{gallery_wrapped} "}
  end

  # def mounting
  #   category_names[0] if category_names.present?
  # end

  def mounting
    category_names[0] if category_names && category_names[0] != "flat"
  end

  #kill
  def framed
    mounting if mounting == "framed"
  end
  #=> framed

  def gallery_wrapped
    wrapped if wrapped == "gallery wrapped"
  end

  def wrapped
    properties["wrapped"] if properties["wrapped"]
  end
  #=> "stretched", "gallery wrapped"

  def stretched
    wrapped if wrapped == "stretched"
  end

  def mount_key
    mounting if ["framed", "wrapped"].include?(mounting)
  end

  def mount_value
    properties[mount_key]
  end

  #kill
  # def descrp(ver)
  #   public_send(ver)
  # end

  def descrp(ver)
    public_send(mount_key + "_" + "descrp", ver, mount_value)
  end

  def frame_descrp(ver, mount_value)
    case
    when ver == "inv" || ver == "tag" then h = {pos: "before", v: mount_key}
    when ver == "body" then mount_clause
    end
  end

  def wrapped_descrp(ver, mount_value)
    case
    when ver == "inv" then h = {pos: "before", pat: "canvas", v: mount_value}
    when ver == "tag" && gallery_wrapped then h = {pos: "before", pat: "canvas", v: mount_value}
    when ver == "body" && stretched then h = {pos: "before", pat: "canvas", v: mount_value}
    when ver == "body" && gallery_wrapped then mount_clause
    end
  end

  def mount_clause
    "This piece comes #{properties[mount_key]}." if mount_key == "framed" || mount_value == "gallery wrapped"
  end

  def dropdown
    properties[category.name]
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
