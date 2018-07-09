require 'active_support/concern'

module Disclaimer
  extend ActiveSupport::Concern

  def quadrant?
    valid_local_keys.include?("quadrant")
  end

  def subcategory?
    valid_local_keys.include?("subcategory")
  end

  def category?
    valid_local_keys.include?("category")
  end

  def general_damage?
    ! quadrant? && ! subcategory? && %w(damage wear).include?(properties["defect"])
  end

  def border_subcategory?
    properties["category"] == "border area"
  end

  def along?
    quadrant? && properties["quadrant"] == "along"
  end

  ###custom
  def custom
    properties["custom"] if properties["custom"].present?
  end

  ###caveat
  def caveat?
    valid_local_keys.include?("caveat")
  end

  def caveat_inspection(k)
    "that #{defect_form} only noticeable upon close inspection." if properties[k] == "inspection"
  end

  def caveat_concealed(k)
    "that may be concealed when framed" if properties[k] == "concealed"
  end

  def format_caveat(k)
    public_send(k + "_" + properties[k], k)
  end

  ###quadrant
  def format_quadrant(k)
    along? ? "#{properties[k]} the" : properties[k]
  end

  ###category
  def format_category(k)
    category = ! caveat? ? "#{properties[k]}." : properties[k]
    case
    when general_damage? then "to the #{category}"
    when quadrant? || subcategory? then "of the #{category}"
    else properties[k]
    end
  end

  ###defect
  def format_defect(k)
    case
    when along? then properties[k]
    when border_subcategory? then "#{properties[k]} in the"
    when general_damage? && ! quadrant? && ! subcategory? then "signs of #{properties[k]}"
    else "#{properties[k]} on the"
    end
  end

  ###disclaimer
  def article
    "a" if %w(damage chipping wear creasing).exclude?(properties["defect"]) && ! plural_defect?
  end

  def plural_defect?
    properties["defect"][-1] == "s"
  end

  def defect_form
    plural_defect? || general_damage? ? "are" : "is"
  end

  def flag(k)
    "Please note:" if %w(alert warning).include?(properties[k])
  end

  def format_disclaimer(k)
    [flag(k), "There", defect_form, article].compact.join(" ")
  end

  def body_disclaimer(keys)
    build = ""
    keys.each do |k|
      next if valid_local_keys.exclude?(k)
      v = respond_to?("format_" + k) ? public_send("format_" + k, k) : properties[k]
      build << pad_pat_for_loop(build, v)
    end
    #build = custom.present? ? "#{build}. #{custom}" : "#{build}."
    properties["disclaimer"] == "note" ?  "#{build}." : "** #{build}. **"
  end

  def tag_disclaimer
    "(Disclaimer)" if properties["disclaimer"] == "alert"
  end

  def inv_disclaimer
    "D-#{properties["disclaimer"]}"
  end

  def build_disclaimer(h, typ, ver)
    h[:v] = ver == "body" ? public_send(ver + "_disclaimer", h[:v]) : public_send(ver + "_disclaimer")
  end
end
