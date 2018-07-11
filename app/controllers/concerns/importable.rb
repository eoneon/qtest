require 'active_support/concern'

module Importable
  extend ActiveSupport::Concern

  class_methods do
    def to_csv(fields = column_names, options = {})
      CSV.generate(options) do |csv|
        csv << fields
        all.each do |item|
          item["frame_width"] = item.frame_width
          item["frame_height"] = item.frame_height
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
