class MountType < ApplicationRecord
  belongs_to :category
  has_many :items

  #for drop down in items forms
  def mounting
    category.name if properties?
  end

  #description
  def mount_description
    properties[mounting] if properties?
  end
end
