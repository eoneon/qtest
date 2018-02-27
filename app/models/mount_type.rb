class MountType < ApplicationRecord
  belongs_to :category
  has_many :items

  #for drop down in items forms
  def category_names
    category.name.split("_")
  end

  def mounting
    category_names & ["framed", "wrapped"]
  end

  def art_type
    category_names & ["original", "print"]
  end

  def substrates
    category_names & ["canvas", "paper"]
  end

  def description
    if mounting.present?
      "#{properties[mounting[0]]} #{art_type[0]}".squish
    else
      category_names.join(" ")
    end
  end

  def context
    case
    when mounting == "frame" then "framed"
    when mounting != "frame" then description
    end
  end

  def substrate
    if properties[mounting] == "gallery wrapped" || properties[mounting] == "stretched" || properties[mounting] == "flat canvas"
      "canvas"
    elsif properties[mounting] == "flat paper"
      "paper"
    end
  end

  def dropdown
    description
  end
end
