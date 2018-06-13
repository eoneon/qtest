require 'active_support/concern'

module Edition
  extend ActiveSupport::Concern

  def insert_article(str)
    idx = str.index(properties["edition"])
    str.insert(idx, "#{format_article(properties["edition"])} ")
  end

  def conjunct_edition(h)
   h[:v] = ver_types("tag").include?("sign") ? "#{h[:v]} and" : h[:v]
  end

  def from_edition(h)
    h[:v] = insert_article(h[:v])
  end

  def strip_edition(str)
    str.split(" ").drop(1).join(" ")
  end

  def edition_field_blank?
    edition_type.category_names[0] == "edition" && properties["edition"].blank? if ver_types("tag").include?("edition")
  end

  def format_dim(h, typ, ver)
    h[:v] = pop_type("dim", h[:v])
  end

  def format_edition(h, typ, ver)
    h[:v] = strip_edition(h[:v]) if edition_field_blank?
    h[:v] = pop_type("edition", h[:v])
    h[:v] = public_send(edition_type.edition_context, h)
  end
end
