class DimType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  scope :framed_dims, -> {where('name LIKE ?', "%frame%")}
  scope :canvas_dims, -> {where(name: "image")}
  scope :border_dims, -> {where('name LIKE ?', "%border%")}

  def self.paper_dims
    canvas_dims + border_dims
  end

  def required_fields
    category_names
  end

  #dimension methods
  def inner_dims
    category_names.keep_if {|name| name.index(/inner/)}
  end

  def outer_dims
    category_names.keep_if {|name| name.index(/outer/)}
  end

  def joined_inner_dims
    inner_dims.join(" x ") #if inner_dims
  end
  #=>innerwidth x innerheight

  def joined_outer_dims
    outer_dims.join(" x ") #if outer_dims
  end
  #=> outerwidth x outerheight

  def targets
    name.split("_")
  end
  #=> [frame, image] / [width, height, weight]

  def outer_target
    targets[0] if category_names[0].index(/outer/) #frame
  end

  def inner_target
    targets[-1] if category_names[-1].index(/inner/) #image
  end

  def targets_2d
    [outer_target, inner_target].reject {|i| i.blank?}
  end
  #=>[frame, image]

  def targets_3d
    targets unless targets_2d.present? #name == category.name
  end
  #=>[width, height, weight]

  def dims_2d
    [joined_outer_dims, joined_inner_dims].reject {|i| i.blank?}
  end
  #=> [outerwidth x outerheight, innerwidth x innerheight]

  def formatted_2d_targets
    [outer_target, inner_target].reject {|i| i.blank?}.map {|t| "(#{t})"}
  end
  #=>["(frame)", "(image)"]

  def body_2d
    dim_arr = dims_2d.zip(formatted_2d_targets) #.join(", ")
    #=> [["outerwidth x outerheight", "(frame)"], ["innerwidth x innerheight", "(image)"]]
    dim_arr.map {|arr| arr.join(" ")}.join(", ")
  end
  #=>"outerwidth x outerheight (frame), innerwidth x innerheight (image)"

  def frame_dims
    outer_dims if outer_target == "frame"
  end

  def xl_dims
    frame_dims ? "(#{joined_outer_dims})" : "(#{joined_inner_dims})"
  end

  def inv_targets_2d
    targets_2d.map {|t| format_inv_targets(t)} unless targets_2d.blank? #.present?
  end
  #=>[“frm:”, “img:”]

  def inv_2d
    inv_targets_2d.zip(dims_2d).map {|i| i.join(" ")}.join(", ") if inv_targets_2d
  end
  #=>“frm: outerwidth x outerheight, img: innerwidth x innerheight”

  def format_inv_targets(t)
    case t
    when "frame" then "frm:"
    when "border" then "brdr:"
    when "image" then "img:"
    when "cel" then "cel:"
    when "image-diameter" then "img-d:"
    when "diameter" then "dia:"
    else "#{t[0]}:"
    end
  end

  def dims_3d
    targets_3d.map {|t| "#{t} (#{t})"}
  end
  #=>["width (width)", "height (height)", "weight (weight)"]

  def inv_dims_3d
    targets_3d.map {|t| "#{format_inv_targets(t)} #{t}"} if targets_3d.present?
  end
  #=>["w: width", "h: height", "w: weight"]

  def format_3d(arr_3d) #dims_3d/inv_dims_3d
    idx = idx_of_i_with_pat(arr_3d, "weight")
    if idx
      [arr_3d.take(idx).join(" x "), arr_3d[idx]].join("; ")
    else
      arr_3d.join(" x ")
    end
  end
  #=> "width (width) x height (height); weight (weight)"
  #=> "w: width x h: height; w: weight"

  def inv_3d
    format_3d(inv_dims_3d) if targets_3d.present?
  end

  def body_3d
    format_3d(dims_3d) if targets_3d.present?
  end
  #=> "width (width) x height (height); weight (weight)"

  def inv_dim
    "(#{[inv_3d, inv_2d].compact.join(" ")})"
  end

  def tag_dim
    h = {pos: "after", occ: 0, v: xl_dims, ws: 1} if dims_2d.present?
  end

  def body_dim
    "Measures approx. #{[body_2d, body_3d].join(" ").strip}."
  end

  def typ_ver_args(ver)
    public_send(ver + "_dim")
  end

  def dropdown
    targets.join(" & ")
  end
end
