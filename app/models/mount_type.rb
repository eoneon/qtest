class MountType < ApplicationRecord
  belongs_to :category
  has_many :items

  def category_names
    category.name.split("_") if category
  end

  def mounting
    category_names[0] if category_names.present?
  end

  def context
    mounting if ["framed", "wrapped"].include?(mounting)
  end

  def tagline_mounting
    if context == "framed"
      context
    elsif context == "wrapped"
      properties[context]
    end
  end

  def description_mounting
    if tagline_mounting == "framed" || tagline_mounting == "gallery wrapped"
      "This piece comes #{properties[context]}."
    end
  end

  def dropdown
    properties[mounting]
  end

  def description
    [tagline_mounting, description_mounting].compact
  end
end
