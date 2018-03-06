class MountType < ApplicationRecord
  belongs_to :category
  has_many :items

  #for drop down in items forms
  def category_names
    category.name.split("_")
  end

  def mounting
    arr = category_names & ["framed", "wrapped"]
    arr[0]
  end

  def art_type
    arr = category_names & ["original", "print"]
    arr[0]
  end

  def substrates
    arr = category_names & ["canvas", "paper"]
    arr[0]
  end

  def description
    "#{properties[mounting]}" if mounting.present?
  end

  def context
    properties[mounting] if mounting.present?
  end

  def substrate
    if mounting == "wrapped" || substrates == "canvas"
      "canvas"
    elsif substrates == "paper"
      "paper"
    end
  end

  def item_filter
    [art_type, substrate].reject {|i| i.blank?}.join("")
  end

  def dim_filter
    framed = mounting if mounting == "framed"
    [framed, substrate].reject {|i| i.blank?}.join("")
  end

  def dropdown
    # description
    if mounting.present?
      "#{properties[mounting]} #{art_type}".squish
    else
      category_names.join(" ")
    end
  end
end
