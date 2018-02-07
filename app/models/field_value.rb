class FieldValue < ApplicationRecord
  has_many :value_groups, dependent: :destroy
  has_many :item_fields, through: :value_groups
end
