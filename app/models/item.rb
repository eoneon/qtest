class Item < ApplicationRecord
  include SharedMethods
  include ObjectMethods
  include Capitalization
  include Dim

  belongs_to :artist_type, optional: true
  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  def key_value(k)
    properties[k] if valid_keys.include?(k)
  end

  def key_value_include?(k, v)
    key_value(k) && key_value(k).split(" ").include?(v)
  end

  #new
  def all_keys
    item_type ? %w(item_type_id artist_type_id edition_type_id sign_type_id mount_type_id cert_type_id dim_type_id) : []
  end
  #new
  def local_keys
    %w(edition_type_id dim_type_id)
  end
  #new
  # def key_value_hsh
  #   h = {"edition" => {k: "unnumbered", v: "not numbered"}, "mount" => {k: "wrapped", v: "stretched"}, "sign" => {k: "signtype", v: "not signed"}, "cert" => {k: "certificate", v:"N/A"}}
  # end

  def valid_local_keys
    properties.map {|k,v| k if v.present?}.compact if properties
  end
  #new
  # def type_key(fk)
  #   key_value_hsh[fk_to_type(fk)]
  # end

  def scoped_properties(fk)
    local_keys.include?(fk) ? properties : fk_to_meth(fk).properties
  end
  #new
  # def key_value_eql?(fk)
  #   scoped_properties(fk)[type_key(fk)[:k]].present? && scoped_properties(fk)[type_key(fk)[:k]] == type_key(fk)[:v]
  # end
  # def key_value_eql?(fk, k, v)
  #   scoped_properties(fk)[:k].present? && scoped_properties(fk)[:k] == [:v]
  # end
  #
  # def valid_tag_fk?(fk, k, v)
  #   key_value_eql?(fk, type_key(fk)[:k], type_key(fk)[:v])
  # end
  # #new
  # def valid_or_unconditional?(fk)
  #   type_key(fk).nil? || ! key_value_eql?(fk) #first step: top-level key present?
  # end
  # #new
  # def valid_body?(fk)
  #   fk
  # end
  # #new
  # def valid_inv?(fk)
  #   valid_or_unconditional?(fk)
  # end
  # #new
  # def valid_tag?(fk)
  #   fk == "dim_type_id" ? xl_dims : valid_or_unconditional?(fk)
  # end

  def valid_type?(ver, fk)
    case
    when fk == "mount_type_id" && fk_to_meth(fk).mount_key == "wrapped" && item_type.valid_keys.exclude?("canvas") then false
    when ver == "tag" && fk == "mount_type_id" && fk_to_meth(fk).mount_value == "streched" then false
    when ver == "tag" && fk == "dim_type_id" && ! xl_dims then false
    when ver != "body" && fk == "edition_type_id" && properties["unnumbered"].present? then false
    when ver != "body" && fk == "sign_type_id" && fk_to_meth(fk).properties["signtype"].present? && fk_to_meth(fk).properties["signtype"] == "not numbered" then false
    when ver != "body" && fk == "cert_type_id" && fk_to_meth(fk).properties["certificate"].present? && fk_to_meth(fk).properties["certificate"] == "N/A" then false
    else true
    end
  end

  #new
  def valid_required_remote_key?(fk)
    fk_to_meth(fk).properties if fk_to_meth(fk)
  end

  def valid_required_local_key?(fk)
    fk_to_meth(fk).required_fields.keep_if {|f| valid_local_keys.include?(f)} == fk_to_meth(fk).required_fields if fk_to_meth(fk)
  end

  def required_properties?(fk)
    local_keys.include?(fk) ? valid_required_local_key?(fk) : valid_required_remote_key?(fk)
  end

  def global_keys
    all_keys.reject{|fk| fk == "mount_type_id" && item_type.valid_keys.exclude?("canvas")}
  end

  def ver_types(ver)
    #global_keys.map {|fk| fk_to_type(fk) if required_properties?(fk) && send("valid_" + ver + "?", fk)}.compact
    global_keys.map {|fk| fk_to_type(fk) if required_properties?(fk) && valid_type?(ver, fk)}.compact
  end

  def order_rules(build, ver, fk)
    case
    when ver != "body" && fk_to_type(fk) == "artist" then insert_at_idx(build, "artist", "item", 0)
    when ver != "body" && fk_to_type(fk) == "mount" && mount_type.mount_value == "framed" then insert_at_idx(build, "mount", "item", 0)
    when fk_to_type(fk) == "mount" && mount_type.mount_value == "wrapped" then insert_at_idx(build, "mount", "item", -1)
    else build << fk_to_type(fk)
    end
  end

  def ordered_keys(ver)
    build = []
    all_keys.each do |fk|
      order_rules(build, ver, fk) if ver_types(ver).include?(fk_to_type(fk))
    end
    build
  end

  ###kill - start here
  # def valid_keys
  #   properties.map {|k,v| k if v.present?}.compact if properties
  # end
  # #kill
  # def valid_remote_key?(k)
  #   fk_to_meth(k).properties unless k == "mount_type_id" && mount_type.wrapped? && item_type.ordered_keys.exclude?("canvas")
  # end
  # #kill
  # def valid_local_key?(k)
  #   fk_to_meth(k).required_fields.keep_if {|field| valid_keys.include?(field)} == fk_to_meth(k).required_fields
  # end
  # #kill
  # def valid_key?(k)
  #   %w(edition_type_id dim_type_id).include?(k) ? valid_local_key?(k) : valid_remote_key?(k)
  # end
  # #kill
  # def type_attr?(k)
  #   k.index(/_type_id/) && fk_to_meth(k) #&& fk_to_meth(k).properties.present?
  # end
  #
  # ##kill
  # def existing_types
  #   item_type ? attribute_names.map {|k| fk_to_type(k) if type_attr?(k) && valid_key?(k) }.compact : []
  # end
  #
  # #kill
  # def valid_existing_types
  #   existing_types.delete_if {|typ| typ == "mount" && mount_type.wrapped? && item_type.ordered_keys.exclude?("canvas")}
  # end
  # #kill
  # def valid_tag_mount?
  #   #mount_type.mount_value != "stretched"
  #   ! mount_type.key_value_eql?("wrapped", "stretched") if mount_type
  # end
  #
  # ##kill
  # def valid_tag_edition?
  #   edition_type.category.name != "unnumbered"
  #   #! edition_type.key_value_eql?("unnumbered", "not numbered") if edition_type
  # end
  # #kill
  # def valid_tag_dim?
  #   xl_dims
  # end
  # #kill
  # def valid_tag_sign?
  #   ! sign_type.key_value_eql?("signtype", "not signed") if sign_type
  # end
  # #kill
  # def valid_tag_cert?
  #   ! cert_type.key_value_eql?("certificate", "N/A") if cert_type
  # end

  #keep
  def from_edition?
    edition_type.category.name == "edition" if ver_types("tag").include?("edition") #includes_edition?
  end
  #keep
  def edition_field_blank?
    edition_type.category_names[0] == "edition" && properties["edition"].blank? if ver_types("tag").include?("edition") #includes_edition?
  end

  #kill
  # def existing_conditional_tag_types
  #   %w(edition dim sign mount) & valid_existing_types if existing_types
  # end
  # #kill
  # def valid_conditional_tag_types
  #   existing_conditional_tag_types.keep_if {|typ| public_send("valid_tag_" + typ + "?")}
  # end
  # #kill
  # def valid_unconditional_tag_types
  #   valid_existing_types - existing_conditional_tag_types
  # end
  # #kill
  # def valid_types
  #   valid_conditional_tag_types + valid_unconditional_tag_types
  # end
  # #keep: refactor
  # def switch_types(list, typ, typ2)
  #   idx = list.index(typ2)
  #   list.delete(typ)
  #   list.insert(idx, typ)
  # end
  #
  # #kill: incorporate re-order
  # def tag_list
  #  list = %w(artist item mount dim edition sign cert).keep_if {|typ| valid_types.include?(typ)}
  #  mount_type && mount_type.mount_value == "framed" ? switch_types(list, "mount", "item") : list
  # end
  # #kill: incorporate re-order
  # def inv_list
  #   tag_list.include?("dim") ? tag_list.delete("dim").push("dim") : tag_list.push("dim")
  # end
  # #kill: incorporate re-order
  # def body_list
  #   list = %w(item artist edition sign mount cert dim) & valid_existing_types
  #   mount_type && mount_type.mount_value == "stretched" ? switch_types(list, "mount", "artist") : list
  # end

  ###- end of kill

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

  def inv_dim(h)
    body_dim(h)
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

  def punct_sign(h, ver)
    case
    when ver != "body" && ver_types("tag").exclude?(fk_to_type("sign")) then h[:v] + "."
    when ver == "body" then h[:v] + "."
    else h[:v]
    end
  end

  def punct_edition(h, ver)
    case
    when edition_type.edition_context == "from_edition" && ver_types("tag").include?("sign") then h[:v] + ","
    when ver != "body" && ! intersection?(ver_types("tag"), "any?", ["sign", "cert"]) then h[:v] + "."
    when ver == "body" && ! ver_types("tag").include?("sign") then h[:v] + "."
    else h[:v]
    end
  end

  def punct_item(h, ver)
    case
    when ! from_edition? && (ver_types("tag").include?("edition") || ver_types("tag").include?("sign")) then h[:v] + ","
    when ver != "body" && ver_types("tag").exclude?("edition") && ver_types("tag").exclude?("sign") && ver_types("tag").exclude?("cert") then h[:v] + "."
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

  def insert_article(str)
    idx = str.index(properties["edition"])
    str.insert(idx, "#{format_article(properties["edition"])} ")
  end

  def strip_edition(str)
    str.split(" ").drop(1).join(" ")
  end

  def conjunct_edition(h)
   h[:v] = ver_types("tag").include?("sign") ? "#{h[:v]} and" : h[:v]
  end

  def from_edition(h)
    h[:v] = insert_article(h[:v])
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
    #public_send(ver + "_list").each do |typ|
    ordered_keys(ver).each do |typ|
      public_send("build_" + typ, h.merge!(typ_args(typ, ver)), typ, ver) if typ_args(typ, ver) && %w(artist item mount edition sign cert dim).include?(typ) #artist mount dim  sign cert
    end
    h[:build]
  end
end
