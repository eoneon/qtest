require 'active_support/concern'

module Capitalization
  extend ActiveSupport::Concern
  #include SharedMethods

  def next_non_alpha(str, idx)
    str.index(/[\s\.\,\?\!\-\;\(\)\"\/]/, idx)
  end

  def word_break(str, idx, max_idx)
    next_non_alpha(str, idx) ? next_non_alpha(str, idx) - 1 : max_idx
  end

  def lower_alpha?(char)
    char =~ /[a-z]/ if char
  end

  def exempt_word?(word)
    %w(a an and or of on with from the x).exclude?(word)
  end

  def word(str, h)
    str[h[:idx]..h[:ridx]]
  end

  def alpha_ridx(str, h)
    h[:idx] < h[:max_idx] ? word_break(str, h[:idx], h[:max_idx]) : h[:idx]
  end

  def cap_conditions(str, h)
    lower_alpha?(word(str, h)[0]) && (exempt_word?(word(str, h)) || h[:i] == 0)
  end

  def alpha_idx(str, h)
    str.index(/[[:alpha:]]/, h[:idx]) if str.index(/[[:alpha:]]/, h[:idx])
  end

  def word_idx_rng(str, h)
    alpha_idx(str, h)
    alpha_ridx(str, h)
  end

  def replace(str, idx, v)
    str.split("").fill(str[idx].upcase, idx, 1).join("")
  end

  def cap_valid_word(str, h)
    h[:idx] = alpha_idx(str, h)
    h[:ridx] = alpha_ridx(str, h)
    cap_conditions(str, h) ? replace(h[:build], h[:idx], h[:build][h[:idx]].upcase) : h[:build]
  end

  def cap(str)
    h = {idx: 0, build: str, max_idx: str.rindex(/[[:alpha:]]/), i: 0}
    while h[:idx] <= h[:max_idx]
      h[:build] = cap_valid_word(str, h)
      h[:idx] = h[:ridx] + 1
      h[:i] +=1
    end
    h[:build]
  end
end
