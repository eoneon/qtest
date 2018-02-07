class ValueGroup < ApplicationRecord
  belongs_to :item_field
  belongs_to :field_value
end
