require 'active_support/concern'

module CsvExport
  extend ActiveSupport::Concern

  # def valid?(k)
  #   item_type.valid_keys.include?(k) if item_type
  # end
  #
  # def value_eql?(k, v)
  #   valid?(k) && properties[k] = v
  # end
  #
  # def split_value(k)
  #   properties[k].split(" ")
  # end
  #
  # def pat_match?(k, v)
  #   split_value(k).include?(v)
  # end
  #
  # def format_diameter(dims, k)
  #   dims["width"] = properties[k]
  #   dims["height"] = properties[k]
  # end

  def framed?
    dim_type.outer_target == "frame"
  end

  # def csv_art_type
  #   v = valid?("print") && ! valid?("limited") ? ["print"] : item_type.valid_keys & %w(original limited sculpturetype book sports)
  #   v[0].gsub("type", "")
  # end

  # def format_sculpture(k)
  #   if valid?("handmade") && value_eql?("handmade", "hand blown glass")
  #     "hand blown glass"
  #   else
  #     properties[k]
  #   end
  # end
  #
  # def format_panel(k)
  #   arr_match?(split_value("panel"), %(metal aluminum)) ? "metal" : "board"
  # end

  # def csv_material
  #   k = %w(paper canvas sericel panel sculpturemedia) & item_type.valid_keys
  #   if %w(paper canvas sericel).include?(k[0])
  #     k[0]
  #   elsif k[0] == "panel"
  #     format_panel(k[0])
  #   elsif k[0] == "sculpturemedia"
  #     format_sculpture(k[0])
  #   end
  # end

  # def csv_dims
  #   dims = {}
  #   dim_type.category_names.each do |k|
  #     case
  #     when %w(width height weight depth).include?(k) then dims[k] = properties[k]
  #     when k.index("diameter") then format_diameter(dims, k)
  #     when k == "innerwidth" || k == "innerheight" then dims[k.gsub("inner", "")] = properties[k]
  #     when framed? && ("outerwidth" || "outerheight") then dims[k.gsub("outer", "frame_" )] = properties[k]
  #     end
  #   end
  #   dims
  # end
end
