require 'active_support/concern'

module SharedMethods
  extend ActiveSupport::Concern

  def test_arr1
    ["abc","efg","123"]
  end

  def test_arr2
    ["abc","efg"]
  end

  def test_str
    "abc efg hijklm"
  end

  #do something if item in first array matches item in second array
  def do_if_i_in_arr2(arr, arr2)
    arr.any? {|i| arr2.include?(i)}
  end

  # def do_i(i)
  #   puts(i)
  # end

  #do something if all items in first array present in second array
  # def do_if_all_i_in_arr2(arr, arr2, do_i(&i))
  #   arr.all? {|i| puts_i(i) if arr2.include?(i)}
  # end

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

  def idx_range_of_pat(str, pat)
    [idx_before_pat(str, pat), idx_after_pat(str, pat) - 1]
  end

  def idx_range_between_split(str, pat)
    [idx_after_pat(str, pat) -1, idx_after_pat(str, pat) + 1 ] if pat
  end

  #insert pattern into string at index
  def insert_pat_at_idx(str, idx, v)
    str.insert(idx, v)
  end

  def insert_join(str, idx_arr, v)
    [str[0..idx_arr[0]], str[idx_arr[1]..-1]].join(v)
  end

  #new:
  def remove_idx_range(str, idx_range)
    str.sub(/#{str[idx_range[0]..idx_range[1]]}/, "")
  end

  #new: integrated insert methods
  def insert_before(str, pat, v)
    idx = idx_before_pat(str, pat)
    insert_pat_at_idx(str, idx, v)
  end

  def insert_after(str, pat, v)
    idx = idx_before_pat(str, pat) + pat.length
    insert_pat_at_idx(str, idx, v)
  end

  def insert_replace(str, pat, v)
    idx_arr = idx_range_of_pat(str, pat)
    str = remove_idx_range(str, idx_arr)
    insert_pat_at_idx(str, idx_arr[0], v)
  end

  #consolidated insert method
  #pos: before, replace, after
  def insert_rel_to_pat(pos:, str:, pat:, v:)
    public_send("insert_" + pos, str, pat, v)
  end

  #replace pattern in string
  def replace_pat(str, idx, v)
    str = str.sub(/#{str[idx[0]..idx[1]]}/, "")
    insert_pat_at_idx(str, idx[0], v)
  end

  def replace_insert(str, pat, v)
    idx_arr = idx_range_of_pat(str, pat)
    replace_pat(str, idx_arr, v)
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


  #extract array items using item index
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
