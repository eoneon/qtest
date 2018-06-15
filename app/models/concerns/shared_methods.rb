require 'active_support/concern'

module SharedMethods
  extend ActiveSupport::Concern

  def test_arr1
    ["a", "b", "c", "d"]
  end

  def test_hash
    hsh = {dogs: []}
  end

  def test_str
    "PSA/DNA".remove("RNA")
  end

  def test_hash
    dog = {fuji: "love", denali: ["self"]}
    dog[:denali] << "cat"
    dog = {fuji: "heart"}
  end

  def category_names
    category.name.split("_") if category
  end

  def pad_pat_for_loop(str, v)
    str.empty? ? v : " #{v}"
  end

  def arr_match?(arr1, arr2)
    arr1.any? {|i| arr2.include?(i)}
  end

  #get index in string relative to pattern
  def idx_before_pat(str, occ, pat)
    idx = occ == 0 ? str.index(/#{pat}/) : str.rindex(/#{pat}/)
  end

  def idx_after_pat(str, occ, pat)
    idx_before_pat(str, occ, pat) + pat.length if pat.present?
  end

  def idx_range_of_pat(str, occ, pat)
    idx = occ == 0 ? str.index(/#{pat}/) : str.rindex(/#{pat}/)
    [idx, idx + pat.length]
  end

  def idx_range_between_split(str, occ, pat)
    [idx_after_pat(str, occ, pat) -1, idx_after_pat(str, occ, pat) + 1 ] if pat && str
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
    [str[0,idx_range[0]], str[idx_range[1]..-1]].join
  end

  #new: integrated insert methods
  def pad(pos, v)
    if pos == "before"
      "#{v} "
    elsif pos == "after"
      " #{v}"
    end
  end

  def insert_before(str, occ, pat, v, ws)
    idx = idx_before_pat(str, occ, pat)
    v = pad("before", v) if ws == 1
    insert_pat_at_idx(str, idx, v)
  end

  def insert_after(str, occ, pat, v, ws)
    idx = idx_before_pat(str, occ, pat) + pat.length
    v = pad("after", v) if ws == 1
    insert_pat_at_idx(str, idx, v)
  end

  def insert_replace(str, occ, pat, v, ws)
    idx_arr = idx_range_of_pat(str, occ, pat)
    str = remove_idx_range(str, idx_arr)
    insert_pat_at_idx(str, idx_arr[0], v)
  end

  #consolidated insert method
  #pos: before, replace, after
  def insert_rel_to_pat(pos:, str:, occ:, pat:, v:, ws:)
    public_send("insert_" + pos, str, occ, pat, v, ws)
  end

  #replace pattern in string
  def replace_pat(str, idx, v)
    str = str.sub(/#{str[idx[0]..idx[1]]}/, "")
    insert_pat_at_idx(str, idx[0], v)
  end

  def replace_insert(str, occ, pat, v, ws)   #added occ & ws
    idx_arr = idx_range_of_pat(str, occ, pat, ws) #added ws
    replace_pat(str, idx_arr, v)
  end

  #get index in array relative to item index
  def idx_before_i(arr, i, occ)
    occ == 0 ? arr.index(i) : arr.rindex(i)
  end

  def idx_after_i(arr, i, occ)
    idx_before_i(arr, i, occ) + 1
  end

  def insert_rel_to_i(pos:, arr:, i:, occ:, v:)
    idx = public_send("idx_" + pos + "_i", arr, i, occ)
    arr.insert(idx, v)
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

  #insert item into array relative (before/after) to other_item
  def first_item?(arr, other_item)
   arr[0] == other_item
  end

  def last_item?(arr, other_item)
    arr[-1] == other_item
  end

  def insert_pos(idx, pos)
    pos == 0 ? idx : idx + 1
  end

  def target_idx(arr, other_item)
    case
    when first_item?(arr, other_item) then 0
    when last_item?(arr, other_item) then -2
    else arr.index(other_item)
    end
  end

  def insert_at_idx(arr, item, other_item, pos)
    idx = target_idx(arr, other_item)
    idx = insert_pos(idx, pos)
    arr.insert(idx, item)
  end

  #new
  def intersection?(arr, filter, test_values)
    test_values.public_send(filter) {|v| arr.include?(v)}
  end
end
