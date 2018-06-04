class Item < ApplicationRecord
  include SharedMethods
  include Capitalization
  include Dim

  belongs_to :artist_type, optional: true
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

  #eg: dependency of valid_existing_types ->validate_properties
  def validate_properties(k)
    if %w(edition_type_id dim_type_id).include?(k)
      validate_properties_required(k)
    elsif fk_to_meth(k) && fk_to_meth(k).properties.present?
      to_type(k)
    end
  end

  def existing_types
    item_type ? attribute_names.map {|k| validate_properties(k) if k.index(/_type_id/) && public_send(k).present?}.compact : []
  end

  def valid_existing_types
    existing_types.delete_if {|typ| typ == "mount" && mount_type.wrapped? && item_type.ordered_keys.exclude?("canvas")}
  end

  def valid_tag_mount?
    mount_type.mount_value != "stretched"
  end

  def valid_tag_edition?
    edition_type.category.name != "unnumbered"
  end

  def valid_tag_dim?
    xl_dims
  end

  def valid_tag_sign?
    ! sign_type.signtype_eql?("not signed") if sign_type
    #! sign_type.key_valid_and_eql?("signtype", "not signed")
  end

  def valid_tag_cert?
    ! cert_type.key_valid_and_eql?("certificate", "N/A") if cert_type
  end

  def includes_edition?
    tag_list.include?("edition")
  end

  def from_edition?
    edition_type.category.name == "edition" if includes_edition?
  end

  def edition_field_blank?
    edition_type.category_names[0] == "edition" && properties["edition"].blank? if includes_edition?
  end

  def includes_sign?
    tag_list.include?("sign")
  end

  def includes_edition_or_sign?
    includes_edition? || includes_sign?
  end

  def includes_edition_and_sign?
    (includes_edition? && ! from_edition?) && includes_sign?
  end

  def existing_conditional_tag_types
    %w(edition dim sign mount) & valid_existing_types if existing_types
  end

  def valid_conditional_tag_types
    existing_conditional_tag_types.keep_if {|typ| public_send("valid_tag_" + typ + "?")}
  end

  def valid_unconditional_tag_types
    valid_existing_types - existing_conditional_tag_types
  end

  def valid_types
    valid_conditional_tag_types + valid_unconditional_tag_types
  end

  def switch_types(list, typ, typ2)
    idx = list.index(typ2)
    list.delete(typ)
    list.insert(idx, typ)
  end

  def tag_list
   list = %w(artist item mount dim edition sign cert).keep_if {|typ| valid_types.include?(typ)}
   mount_type && mount_type.mount_value == "framed" ? switch_types(list, "mount", "item") : list
  end

  def inv_list
    %w(artist item mount edition sign cert dim) & valid_existing_types
  end

  def body_list
    list = %w(item artist edition sign mount cert dim) & valid_existing_types
    mount_type && mount_type.mount_value == "framed" ? switch_types(list, "mount", "artist") : list
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
    end
    str
  end

  def body_dim(h)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def tag_dim(h)
    h2 = h
    h2[:pat] = item_type.xl_dim_ref
    h2[:str] = h2.delete(:build)
    h[:build] = insert_rel_to_pat(h)
  end

  def tag_mount(h)
    insert_rel_to_pat(h)
  end

  def tag_artist(h)
    h[:v]
  end

  def punct_item(h, ver)
    case
    when ! from_edition? && (tag_list.include?("edition") || tag_list.include?("sign")) then h[:v] + ","
    when ver != "body" && tag_list.exclude?("edition") && tag_list.exclude?("sign") && valid_types.exclude?("cert") then h[:v] + "."
    else h[:v]
    end
  end

  def punct_sign(h, ver)
    case
    when ver != "body" && valid_types.exclude?("cert") then h[:v] + "."
    when ver == "body" then h[:v] + "."
    else h[:v]
    end
  end

  def punct_build(h, typ, ver)
    case
    when typ == "item" then punct_item(h, ver)
    when typ == "edition" then punct_edition(h, ver)
    when typ == "sign" then punct_sign(h, ver)
    when typ == "cert" then h[:v] + "."
    else h[:v]
    end
  end

  def conjunct_edition(v)
   "#{v} and" if includes_sign?
  end

  def punct_edition(h, ver)
    case
    when edition_type.edition_context == "from_edition" && valid_tag_sign? then h[:v] + ","
    when ver != "body" && ! valid_tag_sign? && ! valid_tag_cert? then h[:v] + "."
    when ver == "body" && ! valid_tag_sign? then h[:v] + "."
    else h[:v]
    end
  end

  def insert_article(str)
    idx = str.index(properties["edition"])
    str.insert(idx, "#{format_article(properties["edition"])} ")
  end

  def strip_edition(str)
    str.split(" ").drop(1).join(" ")
  end

  def from_edition(h)
    h[:v] = insert_article(h[:v])
    #h[:v] = punct_edition(h[:v])
  end

  def not_from_edition(h)
    h[:v] = conjunct_edition(h[:v])
  end

  def build_edition(h, typ, ver)
    h[:v] = strip_edition(h[:v]) if edition_field_blank?
    h[:v] = pop_type("edition", h[:v])
    h[:v] = public_send(edition_type.edition_context, h)
    #h[:v] = punct_edition(h, ver)
    h[:v] = punct_build(h, typ, ver)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def build_cert(h, typ, ver)
    h[:v] = punct_build(h, typ, ver)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def build_sign(h, typ, ver)
    h[:v] = punct_build(h, typ, ver)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def build_dim(h, typ, ver)
    h[:v] = pop_type("dim", h[:v])
    public_send(ver + "_" + typ, h)
  end

  def mount_ref
    mount_type.framed? ? item_type.frame_ref : "canvas"
  end

  def push_mount(h)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def insert_mount(h)
    insert_rel_to_pat(pos: "before", str: h[:build], occ: 0, pat: mount_ref, v: h[:v], ws: 1)
  end

  def build_mount(h, typ, ver)
    public_send(mount_type.mount_context(ver), h)
  end

  def push_artist(h)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def insert_artist(h)
    insert_rel_to_pat(pos: "after", str: h[:build], occ: 0, pat: item_type.artist_ref, v: h[:v], ws: 1)
  end

  def build_artist(h, typ, ver)
    ver == "body" ? insert_artist(h) : push_artist(h)
  end

  def build_item(h, typ, ver)
    #v = punct_item(h, ver)
    v = punct_build(h, typ, ver)
    h[:build] << pad_pat_for_loop(h[:build], v)
  end

  def typ_args(typ, ver)
    args = type_to_meth(typ).typ_ver_args(ver)
    args.class == String ? h = {v: args} : args
  end

  def build_d(ver)
    h = {build: ""}
    public_send(ver + "_list").each do |typ|
      public_send("build_" + typ, h.merge!(typ_args(typ, ver)), typ, ver) if typ_args(typ, ver) && %w(artist item mount edition sign cert dim).include?(typ) #artist mount dim edition sign cert
    end
    h[:build]
  end
end
