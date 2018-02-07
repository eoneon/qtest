class ItemField < ApplicationRecord
  has_many :field_groups, dependent: :destroy
  has_many :media, through: :field_groups, source: :classifiable, source_type: 'Category'

  has_many :value_groups, dependent: :destroy
  has_many :field_values, through: :value_groups

  accepts_nested_attributes_for :value_groups, reject_if: proc {|attrs| attrs['field_value_id'].blank?}, allow_destroy: true
end
