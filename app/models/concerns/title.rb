require 'active_support/concern'

module Title
  extend ActiveSupport::Concern

  def first_word_in_item
    item_type.typ_ver_args("body").split(" ")[0]
  end

  def title_tag_args
    "\"#{title}\"" #title_inv_args unless title == "untitled"
  end

  def title_inv_args
    title_tag_args
  end

  def title_body_args
    v  = title == "untitled" ? "This" : title_tag_args
    "#{v} is #{format_article(first_word_in_item)}"
  end
end
