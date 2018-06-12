class Item < ApplicationRecord
  include SharedMethods
  include ObjectMethods
  include Capitalization
  include Dim
  include LocalKeyBuild

  belongs_to :artist_type, optional: true
  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  # def key_value(k)
  #   properties[k] if valid_keys.include?(k)
  # end
  #
  # def key_value_include?(k, v)
  #   key_value(k) && key_value(k).split(" ").include?(v)
  # end

  #new
  # def key_value_hsh
  #   h = {"edition" => {k: "unnumbered", v: "not numbered"}, "mount" => {k: "wrapped", v: "stretched"}, "sign" => {k: "signtype", v: "not signed"}, "cert" => {k: "certificate", v:"N/A"}}
  # end

  #new
  # def type_key(fk)
  #   key_value_hsh[fk_to_type(fk)]
  # end

  def all_keys
    item_type ? %w(item_type_id artist_type_id edition_type_id sign_type_id mount_type_id cert_type_id dim_type_id) : []
  end

  def local_keys
    %w(edition_type_id dim_type_id)
  end

  def valid_local_keys
    properties.map {|k,v| k if v.present?}.compact if properties
  end

  def scoped_properties(fk)
    local_keys.include?(fk) ? properties : fk_to_meth(fk).properties
  end

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

  def from_edition?
    edition_type.category.name == "edition" if ver_types("tag").include?("edition") #includes_edition?
  end

  #local_keys
  def edition_field_blank?
    edition_type.category_names[0] == "edition" && properties["edition"].blank? if ver_types("tag").include?("edition") #includes_edition?
  end

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def format_article(pat)
    article_list.any? {|word| word == pat} ? "an" : "a"
  end

  #local_keys:format_metric(k)
  #local_keys: pop_type(typ, str)

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
    when ! from_edition? && intersection?(ver_types("tag"), "any?", ["edition", "sign"]) then h[:v] + ","
    when ver != "body" && ! intersection?(ver_types("tag"), "any?", ["edition", "sign", "cert"]) then h[:v] + "."
    when ver == "body" && ! intersection?(ver_types("tag"), "any?", ["edition", "sign"]) then h[:v] + "."
    else h[:v]
    end
  end

  def punct_cert(h, ver)
    ! [cert_type.body_credential_hsh[:p], cert_type.body_credential_hsh[:n]].include?(h[:v]) ? h[:v] + "." : h[:v] 
    #h[:v] + "." unless h[:v] == [:p, :n].keep_if {|k| cert_type.body_credential_hsh[k] == h[:v]}.compact
  end

  def punct_build(h, typ, ver)
    case
    when typ == "item" then punct_item(h, ver)
    when typ == "edition" then punct_edition(h, ver)
    when typ == "sign" then punct_sign(h, ver)
    when typ == "cert" then punct_cert(h, ver)
    else h[:v]
    end
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

  #local_keys: insert_article(str)
  #local_keys: strip_edition(str)
  #local_keys: conjunct_edition(h)
  #local_keys: from_edition(h)

  def build_edition(h, typ, ver)
    h[:v] = strip_edition(h[:v]) if edition_field_blank?
    h[:v] = pop_type("edition", h[:v])
    h[:v] = public_send(edition_type.edition_context, h)
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
    v = punct_build(h, typ, ver)
    h[:build] << pad_pat_for_loop(h[:build], v)
  end

  def typ_args(typ, ver)
    args = type_to_meth(typ).typ_ver_args(ver)
    args.class == String ? h = {v: args} : args
  end

  def build_d(ver)
    h = {build: ""}
    ordered_keys(ver).each do |typ|
      public_send("build_" + typ, h.merge!(typ_args(typ, ver)), typ, ver) if typ_args(typ, ver) && %w(artist item mount edition sign cert dim).include?(typ) #artist mount dim  sign cert
    end
    h[:build]
  end
end
