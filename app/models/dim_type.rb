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
    inv_targets_2d.zip(dims_2d).join(", ")
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
    [inv_3d, inv_2d].compact
  end

  def tag_dim
    h = {pos: "after", v: xl_dims} if dims_2d.present?
  end

  def body_dim
    "Measures approx. #{[body_2d, body_3d].join(" ")}."
  end

  def typ_ver_args(ver)
    public_send(ver + "_dim")
  end

  #####

  # def grouped_2d_dims
  #   [inner_dims, outer_dims].keep_if {|arr| arr.present?} #[["innerwidth", "innerheight"], ["outerwidth", "outerheight"]]
  # end
  #
  # def grouped_3d_dims
  #   three_d_targets.combination(1).to_a if three_d_targets
  # end
  #
  # def dimensions
  #   grouped_2d_dims.present? ? grouped_2d_dims : grouped_3d_dims
  # end
  #
  # def frame_dims
  #   outer_dims if outer_target == "frame"
  # end

  # def image_dims
  #   inner_dims if inner_target == "image"
  # end

  #tag_dims
  # def xl_dims
  #   frame_dims ? "(#{frame_dims.join(" x ")})" : "(#{inner_dims.join(" x ")})"
  # end

  #target methods
  # def dim_targets
  #   name.split("_") #eg: [frame, image] [innerwidth, innerheight, outerwidth, outerheight]
  # end
  #
  # def outer_target
  #   dim_targets[0] if category_names[0].index(/outer/) #frame
  # end
  #
  # def inner_target
  #   dim_targets[-1] if category_names[-1].index(/inner/) #image
  # end
  #
  # def two_d_targets
  #   [outer_target, inner_target].compact #[frame, image]
  # end
  #
  # def three_d_targets
  #   dim_targets if name == category.name # [width, height, ...]
  # end
  #
  # #kill
  # def weight_index
  #   if three_d_targets.present? && three_d_targets.index("weight")
  #     three_d_targets.index("weight")
  #   end
  # end
  #
  # #avoids if/else
  # def targets
  #   two_d_targets.present? ? two_d_targets : three_d_targets
  # end
  # #=>["frame", "image"]
  #
  # def inv_targets
  #   targets.map {|t| "#{t[0]}:" }
  # end
  #
  # #body_targets
  # def formatted_targets
  #   targets.map {|t| "(#{t})"}
  # end
  #
  # def dim_target_set
  #   dimensions.zip(formatted_targets)
  # end
  # #=>[[["innerwidth", "innerheight"], "(frame)"], [["outerwidth", "outerheight"], "(image)"]]
  #
  # def inv_dim_target_set
  #   dimensions.zip(inv_targets)
  #   #dimensions.zip(formatted_targets)
  # end
  #
  # #values are normalized up to this point.
  # def format_dim_items
  #   dim_target_set.map {|set| format_set(set)}
  # end
  # #=>["innerwidth x innerheight (frame)", "outerwidth x outerheight (image)"]
  #
  # #we want to treat this differently, which is being done because of the behavior of the a single vs double array
  # def format_set(set)
  #   set.take(1).join(" x ") + " " + set.drop(1).join
  # end
  #
  # #body_clause
  # def format_dimensions
  #   if idx_range_of_pat(format_dim_items, "weight")
  #     idx = idx_range_of_pat(format_dim_items, "weight")
  #     d = [format_dim_items.take(idx).join(" x "), format_dim_items.drop(idx).flatten].join("; ") if idx
  #   else
  #     d = format_dim_items.join(", ")
  #   end
  #   "Measures approx. #{d}."
  # end

  def dropdown
    targets.join(" & ")
  end

  # def rule_names
  #   category.name
  # end
end
