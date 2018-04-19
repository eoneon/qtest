require 'active_support/concern'

module Kapitalize
  extend ActiveSupport::Concern

  ##capitalization checks
  def capitalized?(char)
    char[0] == char[0].upcase
  end

  def number?(char)
    char[0] =~ /\d/
  end

  def exempt_words?
    %w(a an and or of on with from the)
  end

  def exempt_punct?
    %w($ , ; . ! ? & -)
  end

  def parenth?(chars)
    chars[0] == "("
  end

  def quote?(chars)
    char[0] == "\""
  end

  def closure?(char)
    parenth?(chars) || quote?(chars)
  end

  def heyphenated?(chars)
    chars.strip != "-" && chars.index(/-/)
  end

  def closure_idx(str)
    str =~ /[\(\)\""]/
  end
end
