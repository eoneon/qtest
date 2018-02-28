class DimType < ApplicationRecord
  belongs_to :category
  has_many :items

  scope :framed_dims, -> {where("properties ? :key", key: "framed")}
  scope :wrapped_dims, -> {where("properties ? :key", key: "wrapped")}
  scope :canvas_dims, -> {where("properties ? :key", key: "canvas")}
  scope :paper_dims, -> {where("properties ? :key", key: "paper")}
  # def name=(name)
  #   write_attribute(:name, category.name)
  # end

  def category_names
    category.name.split("_")
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
    [outer_target, inner_target].reject {|i| i.blank?}
  end

  def three_d_targets
    dim_targets if name == category.name # [width, height, ...]
  end

  def targets
    if two_d_targets.present?
      two_d_targets
    elsif three_d_targets.present?
      three_d_targets
    end
  end

  # def dimension_names
  #   %w(width height depth diameter weight)
  # end

  # def dim_targets
  #   %w(width height depth diameter weight)
  # end

  # def target_names
  #   %w(frame image cel border)
  # end
  #
  # def outer_dims
  #   %w(frame border)
  # end
  #
  # def inner_dims
  #   %w(image cel diameter)
  # end
  #
  # def category_name_first_last
  #   [category_names.first, category_names.first]
  # end
  #
  # def outer_targets
  #   category_names.map {|field| outer_dims.map {|dim| field if field.index(/#{Regexp.quote(dim)}/)}.reject {|i| i.blank?}.join("")}.reject {|i| i.blank?}
  # end

  # def outer_targets
  #   category_names.map {|field| field if field.index(/frame/) || field.index(/border/)}.reject {|i| i.blank?}
  # end

  #
  # def target_arr
  #   [category_names.first, category_names.last]
  # end
  #
  # def targets
  #   dimension_names.map { |dim_name|
  #     target_arr.map { |target|
  #       target.remove(dim_name) if target.index(/#{Regexp.quote(dim_name)}/)
  #     }.reject {|i| i.blank?}.join(" ")
  #   }.reject {|i| i.blank?}.uniq
  # end
  #
  # def first_target
  #   dimension_names.map { |dim| category_names.first.remove(dim) if category_names.first.index(/#{Regexp.quote(dim)}/)}.reject {|i| i.blank?}
  # end

  # def dim_target
  #   dimension_names.map { |dim| dim if category_names.first == dim}.reject {|i| i.blank?}
  # end

  def dropdown
    dim_targets.join(" & ")
  end
end
