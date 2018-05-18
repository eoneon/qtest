require 'active_support/concern'

module Capitalization
  extend ActiveSupport::Concern
  include SharedMethods

  def next_pat_idx(str, pat, idx)
    str.index(/[^\s]/, idx + pat.length)
  end

  def lower_alpha?(pat)
    pat[0] =~ /[a-z]/ if pat
  end

  def exempt_word?(word)
    %w(a an and or of on with from the x).exclude?(word)
  end

  def sub_pat_idx(pat)
    pat.index(/[a-z]/) if pat.index(/[a-z]/) && pat[0] =~ /[^A-Z]/
  end

  def sub_pat_ridx(pat)
    pat.rindex(/[a-z]/) if pat.rindex(/[a-z]/)
  end

  def word_idx(pat, idx)
    idx + sub_pat_idx(pat) if sub_pat_idx(pat)
  end

  def word_ridx(pat, idx)
    idx + sub_pat_ridx(pat) if word_idx(pat, idx)
    #word_idx(pat, idx) + sub_pat_ridx(pat) if sub_pat_idx(pat)
  end

  def word_idxs(pat, idx)
    [word_idx(pat, idx), word_ridx(pat, idx)] if word_idx(pat, idx)
  end

  def word_alpha(str, pat, idx)
    str[word_idxs(pat, idx)[0]..word_idxs(pat, idx)[1]] if word_idxs(pat, idx) && word_idxs(pat, idx)[0].present? && word_idxs(pat, idx)[1].present?
  end

  def exempt_lower_alpha?(str, pat, idx)
    lower_alpha?(word_alpha(str, pat, idx)) && (idx == 0 || exempt_word?(word_alpha(str, pat, idx)))
  end

  def valid_cap_idxs?(str, idx)
    xl_dim_idxs(str).nil? || xl_dim_idxs(str).exclude?(idx)
  end

  def valid_cap_word?(str, pat, idx)
    valid_cap_idxs?(str, idx) && exempt_lower_alpha?(str, pat, idx)
  end

  def cap_word(str, pat, h)
    h.merge!(build: replace_pat(h[:build], word_idxs(pat, h[:idx]), word_alpha(str, pat, h[:idx]).capitalize)) if valid_cap_word?(str, pat, h[:idx])
  end

  def title_upcase(str)
    h = {idx: 0, build: str}
    str.split(" ").each do |pat|
      cap_word(str, pat, h)
      h[:idx] = next_pat_idx(str, pat, h[:idx])
    end
    h[:build]
  end
end
