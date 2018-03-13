class MountType < ApplicationRecord
  belongs_to :category
  has_many :items

  #for drop down in items forms
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

  #kill
  # def art_type
  #   arr = category_names & ["original", "print"]
  #   arr[0]
  # end

  #kill
  # def substrates
  #   arr = category_names & ["canvas", "paper"]
  #   arr[0]
  # end

  def description
    #properties[mounting] if mounting.present?
    [tagline_mounting, description_mounting].compact
  end

  #what is this doing?


  #kill
  # def substrate
  #   if mounting == "wrapped" || substrates == "canvas"
  #     "canvas"
  #   elsif substrates == "paper"
  #     "paper"
  #   end
  # end

  #kill or modify
  # def item_filter
  #   #[art_type, substrate].reject {|i| i.blank?}.join("")
  #   [substrate].reject {|i| i.blank?}.join("")
  # end
  #
  # def dim_filter
  #   framed = mounting if mounting == "framed"
  #   [framed, substrate].reject {|i| i.blank?}.join("")
  # end

  #def dropdown
    # description
    #description
  #   if mounting.present?
  #     "#{properties[mounting]} #{art_type}".squish
  #   else
  #     category_names.join(" ")
  #   end
  #end
end
