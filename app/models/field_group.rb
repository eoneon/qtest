class FieldGroup < ApplicationRecord
  belongs_to :category
  belongs_to :item_field
end
