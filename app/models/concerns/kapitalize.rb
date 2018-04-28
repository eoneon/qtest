require 'active_support/concern'

module Kapitalize
  extend ActiveSupport::Concern

  #kill
  def first_idx(idx)
    idx == 0
  end

  #maybe kill
  def leading_spc?(str, idx)
    str[idx - 1] =~ /\s/ if idx - 1 > 0 #don't want to search end of string if number negative
  end

  #kill
  def word?(str, idx)
    lower?(str, idx) && first_idx(idx) || lower?(str, idx) && leading_spc?(str, idx)
  end

  #start keep
  def end_idx(str)
    str.length - 1
  end

  def lower?(str, idx)
    str[idx] =~ /[a-z]/
  end

  def word_delim
    /[\s\-\",.!?()]/
  end

  def valid_word_for_cap?(word)
    word[0] =~ /[a-z]/ && exempt_word?(word)
  end

  def exempt_word?(chars)
    %w(a an and or of on with from the).exclude?(chars)
  end

  #start
  def first_word_idx(str)
    str.index(/[a-z]/)
  end

  def first_word_ridx(str)
    str.index(word_delim, first_word_idx(str) + 1) - 1
  end

  def first_word_idx_rng(str)
    first_word_idx(str)..first_word_ridx(str)
  end

  def first_word(str)
    first_word_idx_rng(str).map {|i| str[i]}.join("") if first_word_idx_rng(str)
  end
  #end

  #start
  def first_chars_idx_rng(str)
    0..first_word_ridx(str)
  end
  #end

  #start
  def next_chars_idx(str, idx)
    str.index(/[a-z]/, idx + 1) if idx > 0 && str.index(/[a-z]/, idx + 1) > last_word_idx(str)
  end

  def next_chars_ridx(str, idx)
    str.index(word_delim, next_chars_idx(str, idx) + 1)
  end

  def next_chars_idx_rng(str, idx)
    next_chars_idx(str, idx)..next_chars_ridx(str, idx)
  end

  #dup: refactore to take any idx_rng
  def next_word(str, idx)
    next_chars_idx_rng(str, idx).map {|i| str[i]}.join("") if next_chars_idx_rng(str, idx)
  end
  #end

  #word_ridx: :i #=>offset
  def word_end(str, idx)
    idx == end_idx(str) ? idx : str.index(word_delim, idx + 1)
  end

  #start: here!
  def last_chars_idx_rng(str)
    last_word_ridx(str)..-1
  end

  def last_word_ridx(str)
    str.rindex(/[a-z]/)
  end

  #last_word_idx
  def last_word_idx(str)
    str[last_word_ridx(str) - 1] =~ /\s/ ? last_word_ridx(str) : str.rindex(/\s/, last_word_ridx(str) - 1) + 1
  end

  #last_word_idxs
  def last_word_idx_rng(str)
    last_word_idx(str)..last_word_ridx(str)
  end

  def last_word(str)
    str[last_word_idx(str)..last_word_ridx(str)]
  end

  def word_idx_rng(str, idx)
    (idx..word_end(str, idx)) if word?(str, idx) #if valid_word?(d, i)
  end

  def word_str(str, idx)
    word_idx_rng(str, idx).map {|i| str[i]}.join("") if word_idx_rng(str, idx)
  end





  def valid_word?(str, i)
    exempt_word?(word_str(str, idx)) if word?(str, idx)
  end

  def cap_word(word)
    valid_word?(word) ? word.capitalize : word
  end

  #closure methods
  def closure?(str, idx)
    str[idx] =~ /[\"",(]/
  end

  def closure_char(str, idx)
    str[idx] == "\(" ? "\)" : "\""
  end

  def matching_closure(d, i)
    d.index(closure_char(d, i), i + 1)
  end

  def closure_idx_rng(d, i)
    (i..matching_closure(d, i)) if closure?(d, i)
  end

  def closure_content_idx_rng(d, i)
    (i + 1..matching_closure(d, i) - 1)
  end

  def closure_str(d, i)
    closure_idx_rng(d, i).map {|i| d[i]}.join("") if closure_idx_rng(d, i)
  end

  def valid_closure_content?(d, i)
    closure_str(d, i)[1] =~ /[[:alpha:]]/ if closure_str(d, i)
  end

  def closure_content_str(d, i)
    closure_str(d, i)[1..-2] if valid_closure_content?(d, i)
  end

  def sub_pat_at_idxs(str, idx_arg, pat)
    if idx_arg.first == 0
      pat + str[idx_arg.last + 1..-1]
    elsif idx_arg == last_word_idx_rng(str)
      str[0..idx_arg.first - 1] + pat
    else
      str[0..idx_arg.first - 1] + pat + str[idx_arg.last + 1..-1]
    end
  end

  #testing
  def content_loop(h)
    idx = 0
    chars = []
    h[:content].split(h[:delim]).each do |word|
      chars << word[0] =~ /[a-z]/ && exempt_word?(word) || word[0] =~ /[a-z]/ && i == 0 ? word.capitalize : word
      idx += 1
    end
    chars = replace_idxs(closure_str(d, i), closure_idx_rng(d, i), chars.join(h[:delim])) if h[:delim] =~ /-/
    chars.join(h[:delim])
  end

  #kill
  def replace_idxs(d, idx_arg, pat)
    idxs = idx_arg.class == Range ? [idx_arg.first - 1, idx_arg.last + 1] : [idx_arg - 1, idx_arg + 1]
    #[d[0..idxs[0]], d[idxs[1]..-1]].join(pat)
  end

  def delim_idx(content)
    content.index(/[\s,-]/)
  end

  #testing
  def cap_content(d, i, h)
    #delim_idx = h[:content].index(/[\s,-]/) if hyphenated?(h[:content][0]) || closure?(d, i)
    #pat = delim_idx ? content_loop(h.merge!(delim: h[:content][delim_idx])) : h[:content][0].capitalize
    pat = delim_idx(h[:content]) ? content_loop(h.merge!(delim: h[:content][delim_idx])) : h[:content].capitalize
    h.merge!(build: replace_idxs(d, h[:skip_idxs], pat))
  end

  #testing
  def set_hash(d, i, h)
    closure_idx_rng(d, i) ? h.merge!(skip_idxs: closure_idx_rng(d, i), content: closure_str(d, i)) : h.merge!(skip_idxs: word_idx_rng(d, i), content: word_str(d, i))
  end

  #testing
  def cap_chars(d, i, h)
    set_hash(d, i, h)
    cap_content(d, i, h) if valid_word?(d, i) || valid_closure_content?(d, i)
  end

  #testing
  def kapitalize(d)
    i = 0
    build = d
    skip_idxs = []
    h = {}
    [0..end_idx(d)].each do |idx|
      h.merge!(build: build, skip_idxs: skip_idxs)
      cap_chars(d, i, h)
      build = h[:build]
      skip_idxs = h[:skip_idxs]
      i += 1
    end
    build
    #skip_idxs
  end

  #kill
  def exempt_punct?(char)
    %w($ , ; . ! ? & -).include?(char)
  end

  def parenth?(char)
    char[0] == "(" #|| char[0] == ")"
  end

  def hyphenated?(chars)
    chars.strip != "-" && chars.index(/-/)
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

  #replace
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
