require 'active_support/concern'
#include CsvExport
module Importable
  extend ActiveSupport::Concern

  class_methods do

    #
    # def framed?
    #   dim_type.outer_target == "frame"
    # end
    #

    #
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
    #
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
    #


    def to_csv(fields = column_names, options = {})
      CSV.generate(options) do |csv|
        csv << fields
        all.each do |item|
          #item["retail"] = number_to_currency(item["retail"], precision: 2, delimiter: ',')
          item["artist"] = item.artist_name
          item["artist_id"] = item.artist_adminid
          item["tagline"] = item.build_d("tag") if item.item_type
          item["property_room"] = item.build_pr if item.item_type
          item["description"] = item.build_d("body") if item.item_type
          item["width"] = item.csv_dims["width"] if item.dim_type
          item["height"] = item.csv_dims["height"] if item.dim_type
          item["frame_width"] = item.csv_dims["frame_width"] if item.dim_type
          item["frame_height"] = item.csv_dims["frame_width"] if item.dim_type
          item["depth"] = item.csv_dims["depth"] if item.dim_type
          item["weight"] = item.csv_dims["weight"] if item.dim_type
          item["art_type"] = item.item_type.csv_art_type if item.item_type
          item["art_category"] = item.item_type.csv_art_category if item.item_type
          item["medium"] = item.item_type.csv_art_medium if item.item_type
          csv << item.attributes.values_at(*fields)
        end
      end
    end

    def import(file)
      spreadsheet = Roo::Spreadsheet.open(file.path)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        field = find_by(id: row["id"]) || new
        field.attributes = row.to_hash
        field.save!
      end
    end

    def open_spreadsheet(file)
      case File.extname(file.original_filename)
      when ".csv" then Csv.new(file.path, nil, :ignore)
      when ".xls" then Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
      end
    end
  end
end
