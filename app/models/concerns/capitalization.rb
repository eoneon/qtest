require 'active_support/concern'

module Capitalization
  extend ActiveSupport::Concern
  include SharedMethods

  def next_pat_idx(str, pat, idx)
    str.index(/[^\s]/, idx + pat.length + 1)
  end

  def lower_alpha?(pat)
    pat[0] =~ /[a-z]/
  end

  def exempt_word?(word)
    %w(a an and or of on with from the).exclude?(word)
  end

  def sub_pat_idx(pat, idx)
    idx + pat.index(/[a-z]/) if pat.index(/[a-z]/)
  end

  def sub_pat_ridx(pat, idx)
    sub_pat_idx(pat, idx) + pat.rindex(/[a-z]/) if pat.rindex(/[a-z]/)
  end

  def sub_pat_idxs(pat, idx)
    [sub_pat_idx(pat, idx), sub_pat_ridx(pat, idx)] if sub_pat_idx(pat, idx)
  end

  def word_alpha(str, pat, idx)
    str[sub_pat_idxs(pat, idx)[0]..sub_pat_idxs(pat, idx)[1]] if sub_pat_idxs(pat, idx)[0].present? && sub_pat_idxs(pat, idx)[1].present?
  end

  def exempt_lower_alpha?(str, pat, idx)
     exempt_word?(word_alpha(str, pat, idx)) && lower_alpha?(word_alpha(str, pat, idx)) || idx == 0 && lower_alpha?(word_alpha(str, pat, idx))
  end

  def valid_cap_idxs?(str, idx)
    idx < xl_dim_idxs(str)[0] && idx > xl_dim_idxs(str)[-1]
  end

  def valid_cap_word?(str, pat, idx)
    valid_cap_idxs?(str, idx) || exempt_lower_alpha?(str, pat, idx)
  end

  def cap_word(str, pat, h)
    h.merge!(build: replace_pat(h[:build], sub_pat_idxs(pat, h[:idx]), word_alpha(str, pat, h[:idx]).capitalize)) if valid_cap_word?(str, pat, h[:idx])
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
