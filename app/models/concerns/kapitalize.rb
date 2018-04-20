require 'active_support/concern'

module Kapitalize
  extend ActiveSupport::Concern

  ##capitalization checks
  def upper?(char)
    char =~ /[A-Z]/
  end

  def lower?(char)
    char =~ /[a-z]/
  end

  def number?(char)
    char[0] =~ /\d/
  end

  def exempt_word?(chars)
    %w(a an and or of on with from the).include?(chars)
  end

  def exempt_punct?(char)
    %w($ , ; . ! ? & -).include?(char)
  end

  def parenth?(char)
    char[0] == "(" || char[0] == ")"
  end

  def closure?(char)
    char[0] == "(" || char[0] == "\""
  end

  def quote?(chars)
    char[0] == "\""
  end

  def hyphenated?(chars)
    chars.strip != "-" && chars.index(/-/)
  end

  def closure_tag(str)
    idx = closure_idx(str)
    #parenth?(str[idx]) ? ")" : "\""
    str[idx] == "(" ? ")" : "\""
  end

  def close_tag(char)
    char == "(" ? ")" : "\""
  end

  def closure_idx(str)
    str =~ /[\(\)\""]/
  end

  def char_idx(str, char, offset)
    str.index(/#{char}/, offset)
  end

  def closure_loop(d)
    #i, closure_indices = 0, []
    #closure_indices = []
    #d_arr = d.split
    hsh = {i: 0, closure_indices: []}
    d.split.each do |chars|
      hsh[:closure_indices] << hsh[:i] if closure_idx(chars)
      hsh[:i] += 1
    end
    hsh[:closure_indices]
  end


  # def format_closure(str)
  #   to_build = []
  #   end_idx = str.length - 1
  #   while str.length > 0
  #     if closure_idx(str)
  #       open_tag = closure_tag(str)
  #       open_idx = closure_idx(str) #open_idx
  #       #close_tag_idx = str.index(/#{open_tag}/, open_idx + 1) #close_tag_idx
  #       close_tag_idx = str.index(/\)/, open_idx + 1)
  #       to_build << str[0..open_idx - 1] #1st chunk
  #       to_build << str[open_idx..close_tag_idx] #2nd chunk
  #       #3rd chunk
  #       str = str[close_tag_idx + 1..end_idx]
  #     else
  #       to_build << str
  #     end
  #   end
  #   return to_build
  # end
end
