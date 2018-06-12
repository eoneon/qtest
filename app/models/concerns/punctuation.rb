require 'active_support/concern'

module Punctuation
  extend ActiveSupport::Concern

  def set_punct_ver(typ, ver)
    if typ == "item" && ! from_edition? && intersection?(ver_types("tag"), "any?", ["edition", "sign"]) || typ == "edition" && ver_types("tag").include?("sign") ? "global"
      "global"
    elsif ver != "body"
      "title"
    else
      ver
    end
  end
end
