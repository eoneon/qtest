require 'active_support/concern'

module LocalKeyBuild
  extend ActiveSupport::Concern

  def format_metric(k)
    k == "weight" ? "#{k}lbs" : "#{k}\""
  end

  def pop_type(typ, str)
    type_to_meth(typ).category_names.each do |k|
      occ = k == "number" ? -1 : 0
      v = typ == "dim" ? format_metric(properties[k]) : properties[k]
      str = insert_rel_to_pat(pos: "replace", str: str, occ: occ, pat: k, v: v, ws: 0) if str.index(/#{k}/)
    end
    str
  end

  def insert_article(str)
    idx = str.index(properties["edition"])
    str.insert(idx, "#{format_article(properties["edition"])} ")
  end

  def strip_edition(str)
    str.split(" ").drop(1).join(" ")
  end

  def conjunct_edition(h)
   h[:v] = ver_types("tag").include?("sign") ? "#{h[:v]} and" : h[:v]
  end

  def from_edition(h)
    h[:v] = insert_article(h[:v])
  end
end
