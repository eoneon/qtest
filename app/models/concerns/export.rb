require 'active_support/concern'

module Export
  extend ActiveSupport::Concern

  def valid_key?(k)
    item_type.valid_keys.include?(k) if item_type
  end

  def value_eql?(k, v)
    valid_key?(k) && properties[k] = v
  end

  def split_value(k)
    properties[k].split(" ")
  end

  def pat_match?(k, v)
    split_value(k).include?(v)
  end

  def medium
    item_type.medium
  end

  def art_type
    item_type.csv_art_type
  end

  def art_category
    item_type.csv_art_category
  end

  def material
    item_type.csv_material
  end

  def width
    csv_dims["width"]
  end

  def height
    csv_dims["height"]
  end

  def frame_width
    csv_dims["frame_width"]
  end

  def frame_height
    csv_dims["frame_height"]
  end

  def depth
    csv_dims["depth"]
  end

  def weight
    csv_dims["weight"]
  end

  def format_diameter(dims, k)
    dims["width"] = properties[k]
    dims["height"] = properties[k]
  end

  def csv_dims
    dims = {}
    dim_type.category_names.each do |k|
      case
      when %w(width height weight depth).include?(k) then dims[k] = properties[k]
      when k.index("diameter") then format_diameter(dims, k)
      when k == "innerwidth" || k == "innerheight" then dims[k.gsub("inner", "")] = properties[k]
      when framed? && ("outerwidth" || "outerheight") then dims[k.gsub("outer", "frame_" )] = properties[k]
      end
    end
    dims
  end

  def disclaimer
    "yes" if valid_local_keys.include?("disclaimer") && properties["disclaimer"] == "alert" 
  end

  def embellished
    "yes" if item_type.embellished?
  end

  def framed
    "yes" if mount_type && mount_type.framed?
  end

  def stretched
    "yes" if mount_type && mount_type.stretched?
  end

  def gallery_wrapped
    "yes" if mount_type && mount_type.gallery_wrapped?
  end
end
