class FieldValue < ApplicationRecord
  include Importable

  has_many :value_groups, dependent: :destroy
  has_many :item_fields, through: :value_groups

  scope :all_substrate, -> {where(kind: ["canvas", "paper", "panel", "sericel"])}
  scope :paper, -> {where(kind: "paper")}
  scope :painting, -> {where("kind = ? AND name != ?", "painting", "painting")}
end
