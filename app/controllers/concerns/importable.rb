require 'active_support/concern'
#include CsvExport
module Importable
  extend ActiveSupport::Concern

  class_methods do
    def item_keys
      %(artist artist_id tagline property_room description width height frame_width frame_height depth weight art_type art_category medium)
    end

    def to_csv(fields = column_names, options = {})
      CSV.generate(options) do |csv|
        csv << fields
        all.each do |item|
          #item["retail"] = number_to_currency(item["retail"], precision: 2, delimiter: ',')
          item["artist"] = item.public_send("artist")
          item["artist_id"] = item.artist_id
          item["tagline"] = item.tagline if item.item_type
          item["property_room"] = item.property_room if item.item_type
          item["description"] = item.description if item.item_type
          item["width"] = item.width if item.dim_type
          item["height"] = item.height if item.dim_type
          item["frame_width"] = item.frame_width if item.dim_type
          item["frame_height"] = item.frame_height if item.dim_type
          item["depth"] = item.depth if item.dim_type
          item["weight"] = item.weight if item.dim_type
          item["art_type"] = item.art_type if item.item_type
          item["art_category"] = item.art_category if item.item_type
          item["medium"] = item.medium if item.item_type
          item["material"] = item.material if item.item_type
          item["framed"] = item.framed if item.item_type
          item["stretched"] = item.stretched if item.item_type
          item["gallery_wrapped"] = item.gallery_wrapped if item.item_type
          item["embellished"] = item.embellished if item.item_type
          item["disclaimer"] = item.disclaimer
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
