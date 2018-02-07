class ValueGroup < ApplicationRecord
  belongs_to :item_fields
  belongs_to :field_values
end
