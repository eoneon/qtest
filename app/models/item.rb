class Item < ApplicationRecord
  include SharedMethods
  include ObjectMethods
  include Punctuation
  include Capitalization
  include Edition
  include Dim
  include Title
  include PopKeys

  belongs_to :artist_type, optional: true
  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true

  after_initialize :init

  def init
    self.title = "untitled" if title.blank?
  end

  def all_keys
    #item_type ? %w(item_type_id artist_type_id edition_type_id sign_type_id mount_type_id cert_type_id dim_type_id) : []
    item_type ? %w(item_type_id title artist_type_id edition_type_id sign_type_id mount_type_id cert_type_id dim_type_id) : []
  end

  def local_keys
    %w(edition_type_id dim_type_id)
  end

  def item_attrs
    %w(title)
  end

  def valid_local_keys
    properties.map {|k,v| k if v.present?}.compact if properties
  end

  def scoped_properties(fk)
    local_keys.include?(fk) ? properties : fk_to_meth(fk).properties
  end

  def valid_type?(ver, fk)
    case
    #when fk == "title" && (ver == "tag" && title != "untitld" || ver != "tag") then true
    when fk == "mount_type_id" && fk_to_meth(fk).mount_key == "wrapped" && item_type.valid_keys.exclude?("canvas") then false
    when ver == "tag" && fk == "mount_type_id" && fk_to_meth(fk).mount_value == "streched" then false
    when ver == "tag" && fk == "dim_type_id" && ! xl_dims then false
    when ver != "body" && fk == "edition_type_id" && properties["unnumbered"].present? then false
    when ver != "body" && fk == "sign_type_id" && fk_to_meth(fk).properties["signtype"].present? && fk_to_meth(fk).properties["signtype"] == "not numbered" then false
    when ver != "body" && fk == "cert_type_id" && fk_to_meth(fk).properties["certificate"].present? && fk_to_meth(fk).properties["certificate"] == "N/A" then false
    else true
    end
  end

  def present_item_attr?(attr)
    item_attrs.include?(attr) && public_send(attr).present?
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

  # def global_keys
  #   all_keys.reject{|fk| fk == "mount_type_id" && mount_type.mount_key == "wrapped" && item_type.valid_keys.exclude?("canvas")}
  # end

  def ver_types(ver)
    all_keys.map {|k| fk_to_type(k) if present_item_attr?(k) || required_properties?(k) && valid_type?(ver, k)}.compact
    #all_keys.map {|fk| fk_to_type(fk) if required_properties?(fk) && valid_type?(ver, fk)}.compact
  end

  #replce with reorder_typ
  def order_rules(build, ver, fk)
    case
    when ver != "body" && fk_to_type(fk) == "artist" then reorder_items(build, "artist", "item", 0)
    when ver != "body" && fk_to_type(fk) == "mount" && mount_type.mount_value == "framed" then reorder_items(build, "mount", "item", 0)
    when fk_to_type(fk) == "mount" && mount_type.mount_value == "wrapped" then reorder_items(build, "mount", "item", -1)
    else build << fk_to_type(fk)
    end
  end

  #title
  def reorder_title(build, ver)
    reorder_items(build, "title", "item", 0)
  end

  #artist
  def reorder_artist(build, ver)
    # target = ver_types(ver).include?("title") ? "title" : "item"
    # if ver == "body"
    #   build << "artist"
    # else
    #   reorder_items(build, "artist", "title", 0)
    # end
    if ver != "body"
      target = ver_types(ver).include?("title") ? "title" : "item"
      reorder_items(build, "artist", "title", 0)
    end
  end

  #mount
  def reorder_mount(build, ver)
    if ver != "body" && mount_type.mount_key == "framed"
      reorder_items(build, "mount", "item", 0) #if ver != "body" && mount_type.mount_key == "framed"
    end
  end

  #ver_keys(ver)
  def ordered_keys(ver)
    build = []
    #ver_types(ver).each do |fk|
    ver_types(ver).each do |typ|
      #respond_to?("reorder_" + typ) ? public_send("reorder_" + typ, build, ver) : build << typ
      respond_to?("reorder_" + typ) && public_send("reorder_" + typ, build, ver) ? public_send("reorder_" + typ, build, ver) : build << typ
      #order_rules(build, ver, fk) #if ver_types(ver).include?(fk_to_type(fk))
    end
    build
  end

  def from_edition?
    edition_type.edition_context == "from_edition" if ver_types("tag").include?("edition")
  end

  def article_list
    ["HC", "AP", "IP", "original", "etching", "animation", "embellished"]
  end

  def format_article(pat)
    article_list.any? {|word| word == pat} ? "an" : "a"
  end

  def mount_ref
    mount_type.framed? ? item_type.frame_ref : "canvas"
  end

  def assign_dim(h)
    h = {v: xl_dims, str: h[:build],pos: "after", pat: item_type.xl_dim_ref, occ: 0, ws: 1}
  end

  def assign_mount(h)
    h = {v: h[:v], str: h[:build], pos: "before", pat: mount_ref, occ: 0, ws: 1}
  end

  def assign_artist(h)
    h = {v: h[:v], str: h[:build], pos: "after", pat: item_type.artist_ref, occ: 0, ws: 1}
  end

  def push_assign(h)
    h[:build] << pad_pat_for_loop(h[:build], h[:v])
  end

  def push_conditions(h, typ, ver)
    %w(item sign edition cert).include?(typ) || (typ == "artist" && ver != "body") || (typ == "mount" && mount_type.mount_context(ver) == "push") || (typ == "dim" &&  ver != "tag")
  end

  def assign_type(h, typ, ver)
    push_conditions(h, typ, ver) ? push_assign(h) : insert_rel_to_pat(public_send("assign_" + typ, h))
  end

  def build_type(h, typ, ver)
    local_keys.include?(typ + "_type_id") ? public_send("format_" + typ, h, typ, ver) : h[:v]
  end

  def typ_args(typ, ver)
    #args = item_attrs.include?(typ) ? public_send(typ + "_" + ver + "_args") : type_to_meth(typ).typ_ver_args(ver)
    args = type_to_meth(typ).typ_ver_args(ver)
    args.class == String ? h = {v: args} : args
  end

  def build_d(ver)
    h = {build: ""}
    ordered_keys(ver).each do |typ|
      build_type(h.merge!(typ_args(typ, ver)), typ, ver) if typ_args(typ, ver)
      punct_type(h, typ, ver) if %w(item edition sign cert).include?(typ)
      assign_type(h, typ, ver) if typ_args(typ, ver) && %w(item mount artist edition sign cert dim).include?(typ)
    end
    ver == "body" ? h[:build] : title_upcase(h[:build])
  end
end
