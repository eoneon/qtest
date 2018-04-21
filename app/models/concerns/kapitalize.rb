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
    char[0] == "(" #|| char[0] == ")"
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
    #idx = closure_idx(str)
    idx = parenth_idx(str)
    #parenth?(str[idx]) ? ")" : "\""
    str[idx] == "(" ? ")" : "\""
    #str[idx] =~ /\(/ ? /\)/ : "\""
  end

  def close_tag(char)
    #char =~ /\(/ ? ")" : "\""
    #char  == /\(/ ? /\)/ : "\""
    char == "(" ? ")" : "\""
  end

  def closure_idx(str)
    str =~ /[\(\)\""]/
  end

  def parenth_idx(str)
    str.index(")")
  end

  def char_idx(str, char, offset)
    str.index(char, offset)
  end

  def cap_char(h, char)
    exempt_word?(h[:word]) ? h[:char] = char : h[:char] = char.upcase
  end

  def skip_parenth(d, h, char, i)
    idx = i + 1
    end_idx = char_idx(d, ")", 1)
    h.merge!(char: char, skip: idx..end_idx)
  end

  def get_word(h, d, i)
    idx, end_idx = i, d.length - 1
    d[idx..end_idx].split("").each do |char|
      if idx == end_idx
        return h.merge!(char: d[idx])
      elsif exempt_punct?(char) || char =~ /[[:space:]]/
        return h.merge!(word: d[i..idx - 1], skip: [i..idx - 1])#d[i..idx - 1].split("").map {|i| h[:skip] << i})
      end
      idx += 1
    end
  end

  def format_char(d, char, i, h)
    case
    when i == 0 && lower?(char) then h.merge!(char: char.upcase) #hsh[:char] = char.upcase
    when i > 0 && lower?(char) && d[i - 1] =~ /[[:space:]]/ && h[:skip].exclude?(i) then h.merge!(char: cap_char(get_word(h, d, i), char))
    when parenth?(char) then skip_parenth(d, h, char, i)
    else h.merge!(char: char)
    end
  end

  def capitalize(d)
    #i, build, h = 0, [], {char: "", skip: [0]}
    i = 0
    build = []
    skip = [0]
    h = {} #char: "", skip: [0]
    d.split("").each do |char|
      #build << format_char(d, char, i, hsh)
      #hsh = format_char(d, char, i, hsh)
      h[:skip] = skip
      format_char(d, char, i, h)
      skip = h[:skip]
      build << h[:char]
      #build << h[:skip]
      i += 1
    end
    #hsh[:char]
    build.join
    #skip
  end
end
