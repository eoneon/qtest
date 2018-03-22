class Item < ApplicationRecord
  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  def to_method(k)
    public_send(k.remove("_id"))
  end

  def to_clause(k)
    k[-8..-1] == "_type_id" ? k.remove("_type_id") : k.remove("_id")
  end

  #valid_type_assocs
  def valid_types
    attribute_names.map {|k| validate_types(k) if k.index(/_type_id/) && public_send(k).present?}.compact
    #to_method(k) -> use this here and remove: public_send(k).present? and to_method(k) below
  end

  def validate_types(k)
    if k == "edition_type_id" || k == "dim_type_id"
      validate_properties_types(k)
    elsif to_method(k) && to_method(k).properties.present? #to_method neccessary?
      to_clause(k)
    end
  end

  def validate_properties_types(k)
    to_clause(k) if to_method(k).required_fields.keep_if {|field| valid_properties_keys.include?(field)} == to_method(k).required_fields
  end

  def valid_properties_keys
    properties.keep_if {|k,v| v.present?}.keys if properties
  end

  def tagline_list
    %w(item edition sign cert) & valid_types
  end

  def description_list
    %w(item edition sign cert dim) & valid_types
  end

  ###
  def dim_set
    dim_type.dimensions.map {|d| format_dims(d)}
  end

  def format_dims(d)
    d.map {|d| format_metric(d)}
  end

  def format_metric(d)
    d == "weight" ? "#{properties[d]}lbs" : "#{properties[d]}\""
  end

  def join_dims(dim_set, delim)
    dim_set.map {|d| d.join(delim)}
  end

  def insert_targets(d)
    dims = d.zip(dim_type.formatted_targets)
    dims.map {|dims| dims.join(" ")}
  end

  def reformat_three_d(d)
    [d.take(dim_type.weight_index), d.drop(dim_type.weight_index)]
    #dims = d.take(dim_type.weight_index)
    #weight = d.drop(dim_type.weight_index)
  end

  #dim_description
  def branching_dim
    if dim_type.two_d_targets.present?
      d = join_dims(dim_set, " x ")
      d = insert_targets(d)
    elsif dim_type.three_d_targets.present?
      d = insert_targets(dim_set)
      d = reformat_three_d(d)
      #=> [["5\" (width)", "6\" (height)"], ["7lbs (weight)"]]
      d = join_dims(d, " x ")
      #=> ["5\" (width) x 6\" (height)", "7lbs (weight)"]
    end
    delim = dim_type.three_d_targets ? "; " : ", "
    "Measures approx. #{d.join(delim)}."
    #join_dims(d, delim) #wont work here because of different levels?
  end

  ##

  def inner_dim_arr
    dim_type.inner_dims.map {|d| properties[d]} if dim_type && dim_type.inner_dims
  end

  def outer_dim_arr
    dim_type.outer_dims.map {|d| properties[d]} if dim_type && dim_type.outer_dims
  end

  def image_size
    inner_dim_arr[0].to_i * inner_dim_arr[-1].to_i if inner_dim_arr.present? && inner_dim_arr.count >= 1
  end

  def frame_size
    outer_dim_arr[0].to_i * outer_dim_arr[1].to_i if outer_dim_arr.present? && outer_dim_arr.count == 2 && dim_type.outer_target == "frame"
  end

  def plus_size
    if frame_size && frame_size > 1200
      "(#{join_dims(dim_set, " x ")[-1]})"
    elsif frame_size.blank? && image_size && image_size > 1200
      "(#{join_dims(dim_set, " x ")[0]})"
    end
  end

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  #edition methods
  #position methods

  def before_pos(d, target)
    d.index(/#{target}/)
  end

  def after_pos(d, target)
    before_pos(d, target) + target.length if target
  end

  def pos_insert(d, idx, insert_value)
    d.insert(idx, insert_value)
  end

  def split_pos(d, target)
    [ after_pos(d, target) -1, after_pos(d, target) + 1 ] if target
  end

  def split_insert(d, idx_arr, insert_value)
    [ d[0..idx_arr[0] ], d[idx_arr[1]..-1]].join(insert_value)
  end

  def format_type(obj)
    case
    when obj.class == String then obj
    when obj.class == Symbol then public_send(obj)
    when obj.class == Array then public_send(obj[0], *obj.drop(1))
    #when obj.class == Hash then
    end
  end

  #dynamically format as(data_type) methods: -> :d
  # def format_by_type(args)
  #   args.map {|arg| public_send("format_as_" + class_to_str(arg), arg)}
  # end

  def format_as_string(str_arg)
    str_arg
  end

  #:d
  def format_as_symbol(sym_arg)
    public_send(sym_arg)
  end

  #d
  def format_as_array(arr_arg)
    #public_send(arr_arg[0], public_send("format_as_" + class_to_str(arr_arg[1]), arr_arg[1]))
    #args = format_by_type(arr_arg.drop(1))
    #public_send(arr_arg[0], *args)
    public_send(arr_arg[0], *format_by_type(arr_arg.drop(1)))
  end

  def format_as_hash(hsh_arg)
    h = public_send(hsh_arg.assoc("edition").drop(1)[0][0]) #wrinkle: make dynamic
    h = hsh_arg.assoc("edition").drop(1)[0] #wrinkle: make dynamic by passing some version of self.class.to_s/type.string/etc so any type may use this method
    public_send(h[0])[h[1]]
  end

  def class_to_str(obj)
    obj.class.to_s.downcase
  end

  #works
  def joined_type_values(type)
    type_to_m(type).category_names.map {|k| properties[k]}.compact.join(" ")
  end

  #works
  def type_to_m(type)
    public_send(type + "_type")
  end

  #works but ugly
  def insert_d(i, d)
    if i == :d
      d
    elsif i.class == Array
      i.map {|sub_i| sub_i == :d ? d : sub_i}
    else
      i
    end
  end

  def format_by_type(args)
    args.map {|arg| public_send("format_as_" + class_to_str(arg), arg)}
  end

  def test_hash
    Hash["a", 100]
  end

  def fetch_rules(type)
    if joined_type_values(type) #type_description
      d = joined_type_values(type) #assign to var so we can update
      if type_to_m(type).rule_set.assoc(type_to_m(type).rule_names)
        rules = type_to_m(type).rule_set.assoc(type_to_m(type).rule_names).drop(1)
        rules.each do |rule|
          d = [rule[0].map {|i| insert_d(i, d)}]
          d = format_by_type(d).join(" ")
        end
        #d = rules[2]
        #d = rules[0]
        #d = rules[0][0].map {|i| insert_d(i, d)}
        #d = rules[0][0]
        #d = format_by_type([rules[0][0].map {|i| insert_d(i, d)}])
        #d = format_by_type(d)
        #d = format_by_type([rules[0][0].map {|i| insert_d(i, d)}])

        #d = format_by_type([rules[2][0].map {|i| insert_d(i, d)}])

        #working:
        # d = [rules[0][0].map {|i| insert_d(i, d)}]
        # d = format_by_type(d).join(" ")
        # d = [rules[1][0].map {|i| insert_d(i, d)}]
        # d = format_by_type(d).join(" ")
        # d = [rules[2][0].map {|i| insert_d(i, d)}]
        # d = format_by_type(d).join(" ")
        #end

        #d = [rules[1][0].map {|i| insert_d(i, d)}]
        #d = format_by_type(d)
        # rules.each do |rule|
        #   d = rule[0].map {|i| insert_d(i, d)}
          #d = format_by_type(d)
          #d = format_by_type([rule[0].map {|i| insert_d(i, d)}])
          #d = rule
          #d = rule[0]
        #end
      end
      d
    end
  end

 #working but soon to be replaced edition methods
  def article(target)
    article_list.any? {|word| word == target} ? " an " : " a "
  end

  def from_an_edition
    #article = article_list.any? {|word| word == properties["edition"]} ? "an" : "a"
    ["from", article(properties["edition"]), properties["edition"], "edition"].join(" ") #if properties["edition"].present?
  end

  def numbered
    [properties["edition"], properties["numbered"], "#{properties["number"]}/#{properties["size"]}"].join(" ") #if properties["numbered"].present? && properties["number"].present? && properties["size"].present?
  end

  def numbered_qty
    [properties["edition"], properties["numbered"]].join(" ") #if properties["numbered"].present? && properties["number"].blank? && properties["size"].blank?
  end

  def numbered_out_of
    [properties["edition"], properties["numbered"], "out of", properties["size"]].join(" ") #if properties["edition"].present? && properties["numbered"].present? && properties["size"].present?
  end

  def not_numbered
    "This piece is not numbered." #if properties["unnumbered"].present? && properties["unnumbered"] == "not numbered"
  end

  def edition_description
    [public_send(edition_type.dropdown.split(" ").join("_"))]
  end

  ##
  def substrate_kind
    item_type.substrates if item_type
  end

  def before_substrate_pos(build)
    build.index(/#{Regexp.quote(substrate_kind)}/)
    #mount_type.context == "framed" ? 0 : build.index(/#{Regexp.quote(substrate_kind)}/) + substrate_kind.length
  end

  def after_substrate_pos(build)
    before_substrate_pos(build) + substrate_kind.length
  end

  def mounting_pos(build)
    mount_type.context == "framed" ? 0 : before_substrate_pos(build)
  end

  def plus_size_pos(build)
    after_substrate_pos(build)
  end

  #kill
  def substrate_pos(build)
    mount_type.context == "framed" ? 0 : build.index(/#{Regexp.quote(substrate_kind)}/) + substrate_kind.length
  end

  def substrate_value
    "on #{item_type.properties[substrate_kind]}" if substrate_kind == "paper"
  end

  #build methods
  def build_mount
    mount_type.description
  end

  def build_item
    item_type.description
  end

  def build_edition
    edition_description
  end

  def build_sign
    sign_type.description
  end

  def build_cert
    cert_type.description
  end

  #refactor: already handling plus_size
  def build_dim
    [plus_size, branching_dim].reject {|i| i.blank?}
  end

  #start here
  def build_tagline
    tagline_list.map {|type| format_build(public_send("build_" + type)[0], type)}.compact.join(" ")
  end

  #new
  def format_build(build, type)
    build = format_item(build) if type == "item"
    insert_punctuation(type, build)
  end

  #new
  def format_item(build)
    ["mounting", "plus_size"].each do |m|
      build = insert_element(build, m) if public_send(m)
    end
    build.remove(*remove_values)
  end

  #new
  def insert_element(build, m)
    build.insert(public_send(m + "_pos", build), " #{public_send(m)} ").strip
  end

  def mounting
    mount_type.tagline_mounting if mount_type.present?
  end

  #not sure how to make this dynamic
  def remove_values
    arr = ["giclee", "stretched"]
    arr + [/#{Regexp.quote(substrate_value)}/] if substrate_value
  end

  #new
  def insert_punctuation(type, build)
    case
    when type == tagline_list[-1] then punct = "."
    when type == "item" && tagline_list.any? {|w| ["edition", "sign"].include?(w)} then punct = ", "
    when type == "edition" && tagline_list.include?("sign") then punct = " and"
    end
    punct ? build.insert(build.length, punct) : build
  end

  def build_description
    description_list.map {|type| public_send("build_" + type) if valid_types.include?(type)}.reject {|i| i.nil?}
  end
end
