class Category < ApplicationRecord
  include Importable

  has_many :mount_types
  has_many :item_types
  has_many :edition_types
  has_many :sign_types
  has_many :cert_types
  has_many :dim_types

  has_many :field_groups, dependent: :destroy
  has_many :item_fields, through: :field_groups

  scope :canvas_subsrtate, -> {where('name LIKE ?', "%canvas%")}
  scope :paper_subsrtate, -> {where('name LIKE ?', "%paper%")}

  accepts_nested_attributes_for :field_groups, reject_if: proc {|attrs| attrs['item_field_id'].blank?}, allow_destroy: true

  def category_names
    name.split("_")
  end
end
