require 'active_support/concern'

module Kapitalize
  extend ActiveSupport::Concern

  # def number?(char)
  #   char[0] =~ /\d/
  # end

  # def lower?(char)
  #   char =~ /[a-z]/
  # end

  def end_idx(d)
    d.length - 1
  end

  ##new
  def lower?(d, i)
    d[i] =~ /[a-z]/
  end

  def first_idx(i)
    i == 0
  end

  def leading_spc?(d, i)
    d[i - 1] =~ /\s/ if i - 1 > 0 #don't want to search end of string if number negative
  end

  def word_end(d, i)
    i == end_idx(d) ? i : d.index(/[\s,.!?]/, i + 1)
  end

  def word?(d, i)
    lower?(d, i) && first_idx(i) || lower?(d, i) && leading_spc?(d, i) #&& ! exempt_word?(word_str(d, i))
  end

  def exempt_word?(chars)
    %w(a an and or of on with from the).exclude?(chars)
  end

  def valid_word?(d, i)
    exempt_word?(word?(d, i)) if word?(d, i)
  end
  #convert to range?
  def word_idx_rng(d, i)
    [i..word_end(d, i)] if valid_word?(d, i) #leading_spc?(d, i) && lower?(d, i)
  end

  def word_str(d, i)
    word_idx_rng(d, i).map {|i| d[i]}.join("") if word_idx_rng(d, i)
  end

  #closure methods
  def closure?(d, i)
    #char[0] == "(" || char[0] == "\""
    d[i] =~ /[\"",(]/
  end

  def closure_char(d, i)
    #d[i] == "(" ? ")" : "\"" if closure?(d, i)
    d[i] == "\(" ? "\)" : "\""
  end

  def matching_closure(d, i)
    #d[i + 1..end_idx(d)].index(closure_char(d, i)) #need to use offset! also, careful to match string to string and not string to regexp
    d.index(closure_char(d, i), i + 1)
  end

  def closure_idx(str)
    #str =~ /[\(\)\"]/
    str =~ /[\(\"\)]/
  end

  #kill
  def closure_end(d, i)
    d[i + 1..end_idx(d, i)].index(/#{closure_char(d, i)}/)
  end

  def closure_idx_rng(d, i)
    [i..closure_end(d, i)]
  end

  def closure_str(d, i)
    d[i..closure_end(d, i)]
  end

  ###
  def exempt_punct?(char)
    %w($ , ; . ! ? & -).include?(char)
  end

  def parenth?(char)
    char[0] == "(" #|| char[0] == ")"
  end



  # def quote?(chars)
  #   char[0] == "\""
  # end

  def hyphenated?(chars)
    chars.strip != "-" && chars.index(/-/)
  end



  # def close_tag(char)
  #   #char =~ /\(/ ? ")" : "\""
  #   #char  == /\(/ ? /\)/ : "\""
  #   char == "(" ? ")" : "\""
  # end

  def closure_idx(str)
    #str =~ /[\(\)\"]/
    str =~ /[\(\"\)]/
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
        return h.merge!(word: d[i..idx - 1], skip: [i..idx - 1])
      end
      idx += 1
    end
  end

  def leading_spc?(d, i)
    d[i - 1] =~ /[[:space:]]/
  end

  def format_char(d, char, i, h)
    case
    when i == 0 && lower?(char) then h.merge!(char: char.upcase)
    when i > 0 && lower?(char) && leading_spc?(d, i) && h[:skip].exclude?(i) then h.merge!(char: cap_char(get_word(h, d, i), char))
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
