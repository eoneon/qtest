require 'active_support/concern'

module Title
  extend ActiveSupport::Concern

  # def untitled?
  #   title.blank?
  # end

  def title_tag_args
    title_inv_args unless title.blank?
  end

  def title_inv_args
    "\"#{title_upcase(title)}\""
  end

  def title_body_args
    v  = title.blank? ? "This" : title_inv_args
    "#{v} is #{format_article(item_type.typ_ver_args("body"))}"
  end
end
