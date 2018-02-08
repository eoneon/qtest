class Category < ApplicationRecord
  include Importable

  has_many :item_types
  has_many :edition_types
  has_many :sign_types
  has_many :cert_types
  has_many :dim_types

  has_many :field_groups, dependent: :destroy
  has_many :item_fields, through: :field_groups
end
