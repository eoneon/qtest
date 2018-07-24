require 'active_support/concern'

module Title
  extend ActiveSupport::Concern

  def first_word_in_item
    item_type.typ_ver_args("body").split(" ")[0]
  end

  def title_tag_args
    "\"#{title}\"" #title_inv_args unless title == "untitled"
  end

  def item_header
    %w(sku artist inv_title raw_retail).map {|meth| public_send(meth)}.join(" | ")
  end

  def title_body_args
    v  = title == "untitled" || item_type.medium_key == "sculpturemedium" ? "This" : title_tag_args
    "#{v} is #{format_article(first_word_in_item)}"
  end

  def truncated_title
    "\"#{title.truncate(20)}\""
  end

  def inv_title
    title == "untitled" || title.blank? ? "Untitled" : title_tag_args
  end
end
