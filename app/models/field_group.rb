class FieldGroup < ApplicationRecord
  belongs_to :classfiable, polymorphic: true
  belongs_to :item_field
end
