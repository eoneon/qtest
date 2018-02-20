class MountType < ApplicationRecord
  belongs_to :category
  has_many :items

  #for drop down in items forms
  def mounting
    category.name if properties?
  end

  def description
    properties[mounting]
  end

  def context
    case
    when mounting == "frame" then "framed"
    when mounting != "frame" then description
    end
  end

  def dropdown
    description
  end
end
