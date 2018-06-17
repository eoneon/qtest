require 'active_support/concern'

module Dim
  extend ActiveSupport::Concern

  def inner_dim_arr
    dim_type.inner_dims.map {|d| properties[d]} if dim_type && dim_type.inner_dims
  end

  #keep?
  def outer_dim_arr
    dim_type.outer_dims.map {|d| properties[d]} if dim_type && dim_type.outer_dims
  end

  #move: this might stay since it will be used as a virtual attribute
  def image_size
    inner_dim_arr[0].to_i * inner_dim_arr[-1].to_i if inner_dim_arr.present? && inner_dim_arr.count >= 1
  end

  #item-specific so either keep here or move to item-description-specific conern or presentor
  def frame_size
    outer_dim_arr[0].to_i * outer_dim_arr[1].to_i if outer_dim_arr.present? && outer_dim_arr.count == 2 && dim_type.outer_target == "frame"
  end

  #xl_dim methods
  def xl_dim_str(d)
    pop_type("dim", dim_type.xl_dims) if xl_dims
  end

  def xl_dim_idx(d)
    d.index(xl_dim_str(d)) if xl_dim_str(d)
  end

  def xl_dim_ridx(d)
    xl_dim_idx(d) + xl_dim_str(d).length if xl_dim_idx(d)
  end

  def xl_dim_idxs(d)
    xl_dim_idx(d)..xl_dim_ridx(d) if xl_dim_ridx(d)
  end

  #item-specific (refactor ->pattern is dim_type-specific): display-specific -> presentor
  def xl_dims
    frame_size && frame_size > 1200 || frame_size.blank? && image_size && image_size > 1200
  end

  def format_dim(h, typ, ver)
    h[:v] = pop_type("dim", h[:v])
  end
end
