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

  # used on item.rb
  def framed?
    mount_key == "framed"
  end

  # used on item.rb
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

  #3
  def tag_wrapped
    mount_value if mount_value == "gallery wrapped"
  end

  #4
  def inv_wrapped
    mount_value if mount_key == "wrapped"
  end

  #5
  def body_wrapped
    stretched? ? mount_value : mount_clause
    #stretched? ? h = {v: mount_value, context: "insert_mount"} : mount_clause
  end

  #6
  def tag_framed
    mount_key
  end

  #7
  def inv_framed
    tag_framed
  end

  #8
  def body_framed
    mount_clause
  end



  #kill
  # def framed
  #   mount_key if mount_key == "framed"
  # end
  #
  # #kill
  # def wrapped
  #   properties["wrapped"] if properties["wrapped"]
  # end
  # #=> "stretched", "gallery wrapped"
  #
  # #kill
  # def gallery_wrapped
  #   wrapped if wrapped == "gallery wrapped"
  # end
  #
  # #kill
  # def stretched
  #   wrapped if wrapped == "stretched"
  # end
  #
  # #kill
  # def framed_args(ver)
  #   case
  #   when ver == "inv" || ver == "tag" then h = {pos: "before", occ: 0, v: mount_key, ws: 1}
  #   when ver == "body" then mount_clause
  #   end
  # end
  #
  # #kill
  # def wrapped_args(ver)
  #   case
  #   when ver == "inv" then h = {pos: "before", occ: 0, pat: "canvas", v: mount_value, ws: 1}
  #   when ver == "tag" && gallery_wrapped then h = {pos: "before", occ: 0, pat: "canvas", v: mount_value, ws: 1}
  #   when ver == "body" && stretched then h = {pos: "before", occ: 0, pat: "canvas", v: mount_value, ws: 1}
  #   when ver == "body" && gallery_wrapped then mount_clause
  #   end
  # end

  #kill
  # def mount_clause
  #   "This piece comes #{properties[mount_key]}" if mount_key == "framed" || mount_value == "gallery wrapped"
  # end

  #9
  def mount_clause
    "This piece comes #{mount_value}"
  end

  #kill
  # def typ_ver_args(ver)
  #   public_send(mount_key + "_" + "args", ver)
  # end

  #1
  def typ_ver_args(ver)
    public_send(ver + "_" + mount_key) unless mount_key == "flat"
  end

  def dropdown
    properties[category.name]
  end
end
