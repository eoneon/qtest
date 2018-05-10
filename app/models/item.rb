class Item < ApplicationRecord
  include SharedMethods
  include Capitalization
  #include Kapitalize

  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  #eg: "Hello" -> String -> "String" -> "string" *unused utility meth
  def class_to_str(obj)
    obj.class.to_s.downcase
  end

  #eg: "dim_type_id" -> :dim_type
  def fk_to_meth(k)
    public_send(k.remove("_id"))
  end

  #eg: "dim" -> :dim_type
  def type_to_meth(type)
    public_send(type + "_type")
  end

  #eg: "dim_type_id" -> "dim"
  def to_type(k)
    k[-8..-1] == "_type_id" ? k.remove("_type_id") : k.remove("_id")
  end

  #eg: dependency of validate_properties_required
  def valid_properties_required_keys
    properties.keep_if {|k,v| v.present?}.keys if properties
  end

  #eg: dependency of validate_types
  def validate_properties_required(k)
    to_type(k) if fk_to_meth(k).required_fields.keep_if {|field| valid_properties_required_keys.include?(field)} == fk_to_meth(k).required_fields
  end

  #eg: dependency of valid_types ->validate_properties
  def validate_properties(k)
    if %w(edition_type_id dim_type_id).include?(k)
      validate_properties_required(k)
    elsif fk_to_meth(k) && fk_to_meth(k).properties.present?
      to_type(k)
    end
  end

  #eg: (assoc_typs) %w(sku retail item_type_id edition_type_id sign mount_type_id cert_type_id) #=> %w(item edition sign) *unordered list of assoc-typs
  def valid_types
    attribute_names.map {|k| validate_properties(k) if k.index(/_type_id/) && public_send(k).present?}.compact
  end

  #ver_lists
  def tag_list
    arr = %w(item edition sign cert) & valid_types
    if edition_type && edition_type.category.name == "unnumbered"
      arr - ["edition"]
    else
      arr
    end
  end

  def inv_list
    %w(item edition sign cert dim) & valid_types
  end

  def body_list
    #%w(item edition sign mount cert dim) & valid_types
    arr = %w(item edition sign mount cert dim) & valid_types
    mount_type.stretched ? arr - ["mount"] : arr
  end
  #if "stretched" then - mount

  #item-specific (refactor ->pattern is dim_type-specific): display-specific -> presentor
  def xl_dims
    frame_size && frame_size > 1200 || frame_size.blank? && image_size && image_size > 1200
  end

  def type_conditions(typ)
    case
    when typ == "mount" then typ
    when typ == "dim" && xl_dims then typ
    end
  end

  def item_list
    typs = %w(mount dim) & valid_types
    typs.map {|typ| type_conditions(typ)}.compact if typs.present?
  end

  # DESCRIPTION METHOCDS
  def punct(ver, typ, d)
    case
    when typ == public_send(ver + "_list")[-1] && ver != "body" then d + "."
    when typ == "item" && ver == "body" && tag_list.all? {|i| %(edition sign).exclude?(i)} then d + "."
    when typ == "item" && tag_list.any? {|i| %(edition sign).include?(i)} then d + ","
    when typ == "edition" && tag_list.include?("sign") then d + " and"
    when typ == "edition" && ver == "body" && tag_list.exclude?("sign") then d + "."
    when %w(sign mount cert dim).include?(typ) && ver == "body" then d + "."
    else d
    end
  end

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def format_article(pat)
    article_list.any? {|word| word == pat} ? "an" : "a"
  end

  def format_metric(k)
    k == "weight" ? "#{k}lbs" : "#{k}\""
  end

  def pop_type(typ, str)
    type_to_meth(typ).category_names.each do |k|
      occ = k == "number" ? -1 : 0
      v = typ == "dim" ? format_metric(properties[k]) : properties[k]
      str = insert_rel_to_pat(pos: "replace", str: str, occ: occ, pat: k, v: v, ws: 0) if str.index(/#{k}/)
      #str
    end
    str
  end

  def hsh_args_dim(d, t_args)
    hsh_args = {v: pop_type("dim", t_args[:v]), pat: item_type.xl_dim_ref, str: d, occ: 0}
    t_args.merge!(hsh_args)
  end

  def hsh_args_mount(d, t_args)
    t_args[:str] = d
    t_args[:pat] = d if t_args[:v] == "framed"
  end

  def hsh_args_edition(t_args)
    hsh_args = {str: pop_type("edition", t_args[:v]), v: format_article(properties["edition"])}
    t_args.merge!(hsh_args)
  end

  def insert_types(d, ver)
    descrp = ""
    item_list.each do |t|
      t_args = type_to_meth(t).typ_ver_args(ver)
      return d unless t_args.is_a? Hash
      descrp = public_send("hsh_args_" + t, d, t_args)
      descrp = insert_rel_to_pat(t_args)
    end
    descrp
  end

  def format_dim(ver)
    d = dim_type.typ_ver_args(ver)
    pop_type("dim", d)
  end

  def format_mount(ver)
    mount_type.typ_ver_args(ver)
  end

  def format_cert(ver)
    cert_type.typ_ver_args(ver)
  end

  def format_sign(ver)
    sign_type.typ_ver_args(ver)
  end

  def format_edition(ver)
    t_args = edition_type.typ_ver_args(ver)
    return t_args unless t_args.is_a? Hash
    t_args = hsh_args_edition(t_args)
    t_args[:pat] == "from" ? insert_rel_to_pat(t_args) : t_args[:str]
  end

  def format_item(ver)
    d = item_type.typ_ver_args(ver)
    item_list.present? ? insert_types(d, ver) : d
  end

  #xl_dim methods
  def xl_dim_str(d)
    pop_type("dim", dim_type.xl_dims) if xl_dims
  end

  def xl_dim_idx(d)
    build_descrp("tag").index(xl_dim_str(d)) if xl_dim_str(d)
  end

  def xl_dim_ridx(d)
    xl_dim_idx(d) + xl_dim_str(d).length if xl_dim_idx(d)
  end

  #test for range/array behavior
  def xl_dim_idxs(d)
    [xl_dim_idx(d), xl_dim_ridx(d)] if xl_dim_ridx(d)
  end

  #kill
  def delimit(d)
    if xl_dims
      delim = pop_type("dim", dim_type.xl_dims)
    else
      delim = /\s/
    end
    l = delim.length
    build_descrp("tag").rindex(/#{delim}/)
  end

  def build_descrp(ver)
    sub_d = []
    public_send(ver + "_list").each do |typ|
      d = public_send("format_" + typ, ver)
      sub_d << punct(ver, typ, d)
      #cap_loop(ver, sub_d[0])
    end
    sub_d.join(" ")
    #sub_d
  end

  #keep?
  def inner_dim_arr
    dim_type.inner_dims.map {|d| properties[d]} if dim_type && dim_type.inner_dims
  end

  #keep?
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

  #kill-->(might need this)--covered by pos methods + type loop
  # def substrate_kind
  #   item_type.substrate_key if item_type
  # end
  #
  # #refactor as part of loop and kill
  # def substrate_value
  #   "on #{item_type.properties[substrate_kind]}" if substrate_kind == "paper"
  # end
end
