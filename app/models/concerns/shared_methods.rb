require 'active_support/concern'

module SharedMethods
  extend ActiveSupport::Concern

  def test_arr
    ["tyu","345","a", "bz", "c"]
  end

  def test_str
    "abc efg hijklm"
  end

  def category_names
    category.name.split("_")
  end

  #get index in string relative to pattern
  def idx_before_pat(str, pat)
    str.index(/#{pat}/)
  end

  def idx_after_pat(str, pat)
    idx_before_pat(str, pat) + pat.length if pat
  end

  def idx_range_between_split(str, pat)
    [idx_after_pat(str, pat) -1, idx_after_pat(str, pat) + 1 ] if pat
  end

  def idx_range_for_split(str, pat)
    [idx_before_pat(str, pat), idx_after_pat(str, pat) - 1]
  end

  #get index in array relative to item index
  def idx_before_i(arr, i)
    arr.index(i) - 1
  end

  def idx_after_i(arr, i)
    arr.index(i)
  end

  def idx_of_i_with_pat(arr, pat)
    arr.index{|i| i.include?(pat)}
  end

  #insert pattern into string at index
  def insert_pat_at_idx(str, idx, v)
    str.insert(idx, v)
  end

  def insert_join(str, idx_arr, v)
    [str[0..idx_arr[0]], str[idx_arr[1]..-1]].join(v)
  end

  #replace pattern in string
  def replace_pat(str, idx, v)
    str = str.sub(/#{str[idx[0]..idx[1]]}/, "")
    insert_pat_at_idx(str, idx[0], v)
  end

  #Extract array items using item index
  def take_with_i(arr, i)
    arr[0..arr.index(i)]
  end

  def take_until_i(arr, i)
    arr[0..arr.index(i) - 1]
  end

  def drop_before_i(arr, i)
    arr[arr.index(i)..-1]
  end

  def drop_after_i(arr, i)
    arr[arr.index(i) + 1..-1]
  end

  #replace item in array
  def replace_i_at_idx(arr, i, v)
    idx = arr.index(i)
    arr.fill(v, idx, 1)
  end
end
