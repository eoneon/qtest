class Item < ApplicationRecord
  include SharedMethods

  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  def test_arr
    [1,2,3,4,"a", "b", "c"]
  end

  def test_str
    "abc efg hijklm"
  end

  ##move: concern
  def to_method(k)
    public_send(k.remove("_id"))
  end

  ##move: concern
  def to_clause(k)
    k[-8..-1] == "_type_id" ? k.remove("_type_id") : k.remove("_id")
  end

  ##move: concern - validate_types
  #valid_type_assocs
  def valid_types
    attribute_names.map {|k| validate_types(k) if k.index(/_type_id/) && public_send(k).present?}.compact
  end

  #ditto
  def validate_types(k)
    if k == "edition_type_id" || k == "dim_type_id"
      validate_properties_types(k)
    elsif to_method(k) && to_method(k).properties.present? #to_method neccessary?
      to_clause(k)
    end
  end

  #ditto
  def validate_properties_types(k)
    to_clause(k) if to_method(k).required_fields.keep_if {|field| valid_properties_keys.include?(field)} == to_method(k).required_fields
  end

  #ditto
  def valid_properties_keys
    properties.keep_if {|k,v| v.present?}.keys if properties
  end

  #move to description concern -> dependencies with validation
  def tagline_list
    %w(item edition sign cert) & valid_types
  end

  #ditto
  def description_list
    %w(item edition sign cert dim) & valid_types
  end

  ###------->dim_type-specific methods

  #move -> group with dimension-specific description methods
  #kill: already handled inside dim_type.rb #=>["outerwidth", "outerheight", "innerwidth", "innerheight"]
  def dim_set
    dim_type.dimensions.map {|d| format_dims(d)}
  end

  #item-specific but display logic should move -> presenter/decorator?
  def format_dims(d)
    d.map {|d| format_metric(d)}
  end

  #ditto
  def format_metric(d)
    d == "weight" ? "#{properties[d]}lbs" : "#{properties[d]}\""
  end

  #refactor if still needed and move to SharedMethods
  def join_dims(dim_set, delim)
    dim_set.map {|d| d.join(delim)}
  end

  #kill
  def insert_targets(d)
    dims = d.zip(dim_type.formatted_targets)
    dims.map {|dims| dims.join(" ")}
  end

  #kill
  def reformat_three_d(d)
    [d.take(dim_type.weight_index), d.drop(dim_type.weight_index)]
    #dims = d.take(dim_type.weight_index)
    #weight = d.drop(dim_type.weight_index)
  end

  #kill ->rule-feeder logic will cover this
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

  #kill
  def inner_dim_arr
    dim_type.inner_dims.map {|d| properties[d]} if dim_type && dim_type.inner_dims
  end

  #kill
  def outer_dim_arr
    dim_type.outer_dims.map {|d| properties[d]} if dim_type && dim_type.outer_dims
  end

  #move: this might stay since it will be used as a virtual attribute
  def image_size
    inner_dim_arr[0].to_i * inner_dim_arr[-1].to_i if inner_dim_arr.present? && inner_dim_arr.count >= 1
  end

  #item-specific so either keep here or move to item-description-specific conern or presentor
  def frame_size
    outer_dim_arr[0].to_i * outer_dim_arr[1].to_i if outer_dim_arr.present? && outer_dim_arr.count == 2 && dim_type.outer_target == "frame"
  end

  #item-specific (refactor ->pattern is dim_type-specific): display-specific -> presentor
  def plus_size
    if frame_size && frame_size > 1200
      "(#{join_dims(dim_set, " x ")[-1]})"
    elsif frame_size.blank? && image_size && image_size > 1200
      "(#{join_dims(dim_set, " x ")[0]})"
    end
  end

  #display-specific
  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  ###
  #kill
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

  #tbd
  def format_as_string(str_arg)
    str_arg
  end

  #ditto
  def format_as_symbol(sym_arg)
    public_send(sym_arg)
  end

  #ditto
  def format_as_array(arr_arg)
    public_send(arr_arg[0], *format_by_type(arr_arg.drop(1)))
  end

  #ditto
  def format_as_hash(hsh_arg)
    h = public_send(hsh_arg.assoc("edition").drop(1)[0][0]) #wrinkle: make dynamic
    h = hsh_arg.assoc("edition").drop(1)[0] #wrinkle: make dynamic by passing some version of self.class.to_s/type.string/etc so any type may use this method
    public_send(h[0])[h[1]]
  end

  #obj-methods -->group with above
  def class_to_str(obj)
    obj.class.to_s.downcase
  end

  #revisit
  def joined_type_values(type)
    type_to_m(type).category_names.map {|k| properties[k]}.compact.join(" ")
  end

  #obj-methods -->group with above -> but it's type-specific
  def type_to_m(type)
    public_send(type + "_type")
  end

  #tbd
  def insert_d(i, d)
    if i == :d
      d
    elsif i.class == Array
      i.map {|sub_i| sub_i == :d ? d : sub_i}
    else
      i
    end
  end

  #description/item-specific --> presenter
  def format_by_type(args)
    args.map {|arg| public_send("format_as_" + class_to_str(arg), arg)}
  end

  #ditto
  def fetch_rules(type)
    if joined_type_values(type) #type_description
      d = joined_type_values(type) #assign to var so we can update
      if type_to_m(type).rule_set.assoc(type_to_m(type).rule_names)
        rules = type_to_m(type).rule_set.assoc(type_to_m(type).rule_names).drop(1)
        rules.each do |rule|
          d = [rule[0].map {|i| insert_d(i, d)}]
          d = format_by_type(d).join(" ")
        end
      end
      d
    end
  end

 #ditto
  def article(target)
    article_list.any? {|word| word == target} ? " an " : " a "
  end

  #kill
  def from_an_edition
    #article = article_list.any? {|word| word == properties["edition"]} ? "an" : "a"
    ["from", article(properties["edition"]), properties["edition"], "edition"].join(" ") #if properties["edition"].present?
  end

  #kill
  def from_an_edition(d)
    idx = before_pos(d, properties["edition"])
    d = pos_insert(d, idx, " from ")
    idx = before_pos(d, properties["edition"])
    d = pos_insert(d, idx, article(properties["edition"]))
    idx = after_pos(d, properties["edition"])
    d = pos_insert(d, idx, " edition ")
  end

  #kill
  def numbered
    [properties["edition"], properties["numbered"], "#{properties["number"]}/#{properties["size"]}"].join(" ") #if properties["numbered"].present? && properties["number"].present? && properties["size"].present?
  end

  # def numbered(d)
  #   idx = split_pos(d, properties["number"])
  #   split_insert(d, idx, "/")
  # end

  #kill
  def numbered_qty
    [properties["edition"], properties["numbered"]].join(" ") #if properties["numbered"].present? && properties["number"].blank? && properties["size"].blank?
  end

  #kill
  def numbered_out_of
    [properties["edition"], properties["numbered"], "out of", properties["size"]].join(" ") #if properties["edition"].present? && properties["numbered"].present? && properties["size"].present?
  end

  #kill-->incorporate into item/edition-specific presenter
  def not_numbered
    "This piece is not numbered." #if properties["unnumbered"].present? && properties["unnumbered"] == "not numbered"
  end

  #kill-->taken over by type loop
  def edition_description
    [public_send(edition_type.dropdown.split(" ").join("_"))]
  end

  ###--------------->incorporate item-specific feeder loop
  #kill-->(might need this)--covered by pos methods + type loop
  def substrate_kind
    item_type.substrates if item_type
  end

  #refactor as part of loop and kill
  def before_substrate_pos(build)
    build.index(/#{Regexp.quote(substrate_kind)}/)
    #mount_type.context == "framed" ? 0 : build.index(/#{Regexp.quote(substrate_kind)}/) + substrate_kind.length
  end

  #refactor as part of loop and kill
  def after_substrate_pos(build)
    before_substrate_pos(build) + substrate_kind.length
  end

  #refactor as part of loop and kill
  def mounting_pos(build)
    mount_type.context == "framed" ? 0 : before_substrate_pos(build)
  end

  #refactor as part of loop and kill
  def plus_size_pos(build)
    after_substrate_pos(build)
  end

  #kill
  def substrate_pos(build)
    mount_type.context == "framed" ? 0 : build.index(/#{Regexp.quote(substrate_kind)}/) + substrate_kind.length
  end

  #refactor as part of loop and kill
  def substrate_value
    "on #{item_type.properties[substrate_kind]}" if substrate_kind == "paper"
  end

  #refactor as part of loop
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

  #refactor as part of loop
  def format_build(build, type)
    build = format_item(build) if type == "item"
    insert_punctuation(type, build)
  end

  #refactor as part of loop
  def format_item(build)
    ["mounting", "plus_size"].each do |m|
      build = insert_element(build, m) if public_send(m)
    end
    build.remove(*remove_values)
  end

  #kill
  def insert_element(build, m)
    build.insert(public_send(m + "_pos", build), " #{public_send(m)} ").strip
  end

  def mounting
    mount_type.tagline_mounting if mount_type.present?
  end

  #refactor as part of loop
  def remove_values
    arr = ["giclee", "stretched"]
    arr + [/#{Regexp.quote(substrate_value)}/] if substrate_value
  end

  #refactor as part of loop
  def insert_punctuation(type, build)
    case
    when type == tagline_list[-1] then punct = "."
    when type == "item" && tagline_list.any? {|w| ["edition", "sign"].include?(w)} then punct = ", "
    when type == "edition" && tagline_list.include?("sign") then punct = " and"
    end
    punct ? build.insert(build.length, punct) : build
  end

  #combine with taglist somehow so we only perform single loop
  #could build 2d-array and then reorder according to description list...or not
  def build_description
    description_list.map {|type| public_send("build_" + type) if valid_types.include?(type)}.reject {|i| i.nil?}
  end
end
