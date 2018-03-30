class MountType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  # def category_names
  #   category.name.split("_") if category
  # end

  def mounting
    category_names[0] if category_names.present?
  end

  def context
    mounting if ["framed", "wrapped"].include?(mounting)
  end

  #kill
  def tagline_mounting
    if context == "framed"
      context
    elsif context == "wrapped"
      properties[context]
    end
  end

  #kill
  def description_mounting
    if tagline_mounting == "framed" || tagline_mounting == "gallery wrapped"
      "This piece comes #{properties[context]}."
    end
  end

  def dropdown
    properties[mounting]
  end

  #kill
  def description
    [description_mounting]
  end

  def stub
    case
    when mounting == "framed" then ["framed", "This piece comes #{properties[context]}."]
    when mounting == "wrapped" then [properties[context]]
    end
  end
end
