require 'active_support/concern'

module SharedMethods
  extend ActiveSupport::Concern

  def test_arr
    ["tyu","345","a", "bz", "c"]
  end

  def test_str
    "abc efg hijklm"
  end

  #orgnizational filter
  def category_names
    category.name.split("_")
  end

  #str pos methods
  def before_pos(str, sub_str)
    str.index(/#{sub_str}/)
  end

  def after_pos(str, sub_str)
    before_pos(str, sub_str) + sub_str.length if sub_str
  end

  def split_pos(str, sub_str)
    [after_pos(str, sub_str) -1, after_pos(str, sub_str) + 1 ] if sub_str
  end


  def replace_pos(str, sub_str)
    [before_pos(str, sub_str), after_pos(str, sub_str) - 1]
  end

  #str insert methods
  def pos_insert(str, idx, v)
    str.insert(idx, v)
  end

  def split_insert(str, idx_arr, v)
    [str[0..idx_arr[0]], str[idx_arr[1]..-1]].join(v)
  end

  def replace_insert(str, idx, v)
    str = str.sub(/#{str[idx[0]..idx[1]]}/, "")
    pos_insert(str, idx[0], v)
  end
  #=>[[12", 12", (frame)], [6", 6", (image)]]

  #array pos methods
  def split_before_pos(arr, i)
    arr.index(i) - 1
  end

  def split_after_pos(arr, i)
    arr.index(i)
  end

  def take_pos(arr, i)
    arr.take(arr.index(i) + 1)
  end

  def drop_pos(arr, i)
    arr.drop(arr.index(i) + 1)
  end

  def pat_pos(arr, pat)
    arr.index{|i| i.include?(pat)}
  end

  ###

  def get_until_i(arr, i)
    arr[0..arr.index(i) - 1]
  end

  def get_thru_i(arr, i)
    arr[0..arr.index(i)]
  end

  def get_after_i(arr, i)
    arr[arr.index(i) + 1..-1]
  end

  def get_from_i(arr, i)
    arr[arr.index(i)..-1]
  end

  #arr insert methods
  def a_replace_insert(arr, i, v)
    idx = arr.index(i)
    arr.fill(v, idx, 1)
  end
end
