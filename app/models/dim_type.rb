class DimType < ApplicationRecord
  belongs_to :category
  has_many :items

  scope :framed_dims, -> {where('name LIKE ?', "%frame%")}
  scope :canvas_dims, -> {where(name: "image")}
  scope :border_dims, -> {where('name LIKE ?', "%border%")}

  def self.paper_dims
    canvas_dims + border_dims
  end

  def category_names
    category.name.split("_")
  end

  def required_fields
    category_names
  end

  def inner_dims
    category_names.keep_if {|name| name.index(/inner/)}
  end

  def outer_dims
    category_names.keep_if {|name| name.index(/outer/)}
  end

  def grouped_2d_dims
    [inner_dims, outer_dims].keep_if {|arr| arr.present?}
  end

  def grouped_3d_dims
    three_d_targets.combination(1).to_a if three_d_targets
  end

  def dimensions
    #accounting for differning number of nested levels
    if grouped_2d_dims.present?
      grouped_2d_dims
    elsif grouped_3d_dims.present?
      grouped_3d_dims
    end
  end

  def dim_targets
    name.split("_")
  end

  def outer_target
    dim_targets[0] if category_names[0].index(/outer/) #frame
  end

  def inner_target
    dim_targets[-1] if category_names[-1].index(/inner/) #image
  end

  def two_d_targets
    [outer_target, inner_target].compact
  end

  def three_d_targets
    dim_targets if name == category.name # [width, height, ...]
  end

  def weight_index
    if three_d_targets.present? && three_d_targets.index("weight")
      three_d_targets.index("weight")
    end
  end

  def targets
    if two_d_targets.present?
      two_d_targets
    elsif three_d_targets.present?
      three_d_targets
    end
  end

  def formatted_targets
    targets.map {|t| "(#{t})"}
  end

  def dropdown
    dim_targets.join(" & ")
  end
end
