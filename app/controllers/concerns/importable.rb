require 'active_support/concern'
#include CsvExport
module Importable
  extend ActiveSupport::Concern

  class_methods do
    def item_keys
      %(artist artist_id tagline property_room description width height frame_width frame_height depth weight art_type art_category medium material framed stretched gallery_wrapped embellished disclaimer)
    end

    def to_csv(fields = column_names, options = {})
      CSV.generate(options) do |csv|
        csv << fields
        all.each do |item|
          fields.map {|k| item[k] = item.public_send(k) if item_keys.include?(k)}
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
