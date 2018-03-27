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

  #orgnizatinoal methods
  # def category_names
  #   category.name.split("_")
  # end

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

  def grouped_2d_dims
    [inner_dims, outer_dims].keep_if {|arr| arr.present?} #[["innerwidth", "innerheight"], ["outerwidth", "outerheight"]]
  end

  def grouped_3d_dims
    three_d_targets.combination(1).to_a if three_d_targets
  end

  def dimensions
    grouped_2d_dims.present? ? grouped_2d_dims : grouped_3d_dims
  end

  #target methods
  def dim_targets
    name.split("_") #eg: [frame, image] [innerwidth, innerheight, outerwidth, outerheight]
  end

  def outer_target
    dim_targets[0] if category_names[0].index(/outer/) #frame
  end

  def inner_target
    dim_targets[-1] if category_names[-1].index(/inner/) #image
  end

  def two_d_targets
    [outer_target, inner_target].compact #[frame, image]
  end

  def three_d_targets
    dim_targets if name == category.name # [width, height, ...]
  end

  #kill
  def weight_index
    if three_d_targets.present? && three_d_targets.index("weight")
      three_d_targets.index("weight")
    end
  end

  def targets
    two_d_targets.present? ? two_d_targets : three_d_targets
  end
  #=>["frame", "image"]

  #combining/formatting dimensions & targets
  def formatted_targets
    targets.map {|t| "(#{t})"}
  end

  def dim_target_set
    dimensions.zip(formatted_targets)
  end
  #=>[[["innerwidth", "innerheight"], "(frame)"], [["outerwidth", "outerheight"], "(image)"]]

  #values are normalized up to this point.
  def format_dim_items
    dim_target_set.map {|set| format_set(set)}
  end

  #we want to treat this differently, which is being done because of the behavior of the a single vs double array
  def format_set(set)
    set.take(1).join(" x ") + " " + set.drop(1).join
  end

  def format_dimensions
    if idx_range_of_pat(format_dim_items, "weight")
      idx = idx_range_of_pat(format_dim_items, "weight")
      d = [format_dim_items.take(idx).join(" x "), format_dim_items.drop(idx).flatten].join("; ")
    else
      d = format_dim_items.join(", ")
    end
    "Measures approx. #{d}."
  end

  def dropdown
    dim_targets.join(" & ")
  end

  def rule_names
    category.name
  end
end
