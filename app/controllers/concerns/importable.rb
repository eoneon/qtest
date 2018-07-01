require 'active_support/concern'

module Importable
  extend ActiveSupport::Concern

  class_methods do
    # def to_csv(options = {})
    def to_csv(fields = column_names, options = {})
      CSV.generate(options) do |csv|
        csv << fields

        #invoice.item.each do |field|
        all.each do |field|
          #csv << field.attributes.values_at(*column_names)
          #field["tagline"] = Item.tagline
          csv << field.attributes.values_at(*fields)
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
