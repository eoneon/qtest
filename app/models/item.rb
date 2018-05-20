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

  #eg: dependency of existing_types ->validate_properties
  def validate_properties(k)
    if %w(edition_type_id dim_type_id).include?(k)
      validate_properties_required(k)
    elsif fk_to_meth(k) && fk_to_meth(k).properties.present?
      to_type(k)
    end
  end

  #eg: (assoc_typs) %w(sku retail item_type_id edition_type_id sign mount_type_id cert_type_id) #=> %w(item edition sign) *unordered list of assoc-typs
  def existing_types
    attribute_names.map {|k| validate_properties(k) if k.index(/_type_id/) && public_send(k).present?}.compact
  end

  def valid_edition?
    edition_type && edition_type.category.name != "unnumbered"
  end

  def valid_dim?
    dim_type && xl_dims
  end

  def valid_sign?
    sign_type && sign_type.sign_context != "unsigned"
  end

  # def valid_types(typ)
  #   true unless ! valid_edition?(typ) && ! valid_sign?(typ) && ! valid_dim?(typ)
  # end

  # def conditional_tag_types
  #   %w(edition dim sign).keep_if {|typ| "valid_" + typ + "?"}
  # end

  # def valid_types(typ)
  #   %w(edition dim sign).keep_if {|typ| "valid_" + typ + "?"}
  # end

  def includes_edition?
    tag_list.include?("edition")
  end

  def includes_sign?
    tag_list.include?("sign")
  end

  def includes_edition_or_sign?
    includes_edition? || includes_sign?
  end

  def includes_edition_and_sign?
    includes_edition? && includes_sign?
  end

  def conditional_tag_types
    %w(edition dim sign)
  end

  def valid_conditional_types(typ)
    existing_types.include?(typ) && conditional_tag_types.keep_if {|typ| "valid_" + typ + "?"}
  end

  def valid_unconditional_types(typ)
    existing_types.include?(typ) && conditional_tag_types.exclude?(typ)
  end

  def valid_types(typ)
    valid_unconditional_types(typ) || valid_conditional_types(typ)
  end

  def tag_list
   %w(artist item mount dim edition sign cert).keep_if {|typ| valid_types(typ)}
  end

  def pad_pat_for_loop(str, v)
    str.empty? ? v : " #{ v}"
  end

  #ver_lists
  # def tag_list
  #   arr = %w(artist item edition sign cert) & existing_types
  #   if edition_type && edition_type.category.name == "unnumbered"
  #     arr - ["edition"]
  #   else
  #     arr
  #   end
  # end

  def inv_list
    %w(artist item edition sign cert dim) & existing_types
  end

  def body_list
    #%w(item edition sign mount cert dim) & existing_types
    arr = %w(item edition sign mount cert dim) & existing_types
    mount_type.stretched ? arr - ["mount"] : arr
  end

  def type_conditions(typ)
    case
    when typ == "mount" then typ
    when typ == "artist" then typ
    when typ == "dim" && xl_dims then typ
    end
  end

  def item_list
    typs = %w(mount artist dim) & existing_types
    typs.map {|typ| type_conditions(typ)}.compact if typs.present?
  end

  # DESCRIPTION METHOCDS
  def punct(ver, typ, d)
    case
    #when typ == "artist" && ver != "body" then d + " - "
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

  def hsh_args_artist(d, t_args)
    hsh_args = {str: d, pat: item_type.artist_ref}
    #hsh_args = {str: d, pat: d}
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

  def format_artist(ver)
    artist_type.typ_ver_args(ver)
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

  def build_descrp(ver)
    sub_d = []
    public_send(ver + "_list").each do |typ|
      d = public_send("format_" + typ, ver)
      sub_d << punct(ver, typ, d)
    end
    #title_upcase(sub_d.join(" "))
    sub_d.join(" ")
  end

  ####start
  def insert_mount(h)
    h[:pat] = item_type.frame_ref_key if h[:v] == "framed"
    h_args = {str:  h[:build]}
    h_args.merge!(h)
    h_args.delete(:build)
    #h[:build] = insert_rel_to_pat(h_args)

    h[:build] << h_args.to_s
  end

  def tag_mount(h)
    #insert_mount(h)
    #h[:pat] = item_type.frame_ref_key if h[:v] == "framed"
    pat = h[:v] == "framed" ? item_type.frame_ref_key : h[:pat]
    h[:build] = insert_rel_to_pat(pos: h[:pos], str: h[:build], occ: h[:occ], pat: pat, v: h[:v], ws: h[:ws])
  end

  def tag_artist(h)
    h[:v]
  end

  def tag_item(h)
    "#{h[:v]}," if includes_edition_or_sign?
  end

  def build_mount(h, typ, ver)
    public_send(ver + "_" + typ, h)
    #h[:build] << h.to_s
  end

  def build_artist(h, typ, ver)
    v = public_send(ver + "_" + typ, h)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def build_item(h, typ, ver)
    v = public_send(ver + "_" + typ, h)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def typ_args(typ, ver)
    v = type_to_meth(typ).typ_ver_args(ver)
    v.class == String ? h = {v: v} : v
  end

  def build_d(ver)
    h = {build: ""}
    public_send(ver + "_list").each do |typ|
      public_send("build_" + typ, h.merge!(typ_args(typ, ver)), typ, ver) if %w(item artist mount).include?(typ)
    end
    h[:build]
  end
end
