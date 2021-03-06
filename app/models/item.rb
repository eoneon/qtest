class Item < ApplicationRecord
  attribute :frame_width
  attribute :frame_height
  attribute :width
  attribute :height

  attribute :depth
  attribute :weight
  attribute :width
  attribute :height

  attribute :artist
  attribute :artist_id

  attribute :tagline
  attribute :property_room
  attribute :description

  attribute :art_type
  attribute :art_category
  attribute :medium
  attribute :material
  attribute :framed
  attribute :stretched
  attribute :gallery_wrapped
  attribute :embellished
  attribute :disclaimer

  include ActionView::Helpers::NumberHelper
  include Importable
  include SharedMethods
  include ObjectMethods
  include Punctuation
  include Capitalization
  include Edition
  include Dim
  include Disclaimer
  include Sign
  include Title
  include Retail
  include Proom
  include PopKeys
  include Export

  has_many :notes, as: :noteable, dependent: :destroy

  #optional: true: https://github.com/thoughtbot/shoulda-matchers/issues/870
  belongs_to :artist_type, optional: true
  belongs_to :mount_type, optional: true
  belongs_to :item_type, optional: true
  belongs_to :edition_type, optional: true
  belongs_to :sign_type, optional: true
  belongs_to :cert_type, optional: true
  belongs_to :dim_type, optional: true
  belongs_to :disclaimer_type, optional: true
  belongs_to :invoice, optional: true
  belongs_to :flag, optional: true

  attr_accessor :skus

  #validates :sku, presence: true, numericality: true, uniqueness: true, length: { is: 6 }
  #scope :invoice_skus, -> {where(invoice_id: self.invoice_id)}

  #after_initialize :init
  before_save :init

  def init
    self.title = "untitled" if title.blank?
    self.retail = 0 if retail.blank?
  end

  def toggle_flag
    if flag.nil?
      "pending"
    else
      flag.first.flag
    end
  end

  def framed?
    dim_type.outer_target == "frame"
  end

  def artist
    artist_type.full_name if artist_type
  end

  def truncated_artist
    artist.truncate(15)
  end

  def artist_id
    artist_type.adminid if artist_type
  end

  def all_keys
    item_type ? %w(item_type_id title artist_type_id edition_type_id sign_type_id mount_type_id cert_type_id dim_type_id disclaimer_type_id) : []
  end

  def local_keys
    %w(edition_type_id dim_type_id disclaimer_type_id)
  end

  def item_attrs
    %w(title)
  end

  def valid_local_keys
    properties.map {|k,v| k if v.present?}.compact if properties.present?
  end

  def scoped_properties(fk)
    local_keys.include?(fk) ? properties : fk_to_meth(fk).properties
  end

  def valid_type?(ver, fk)
    case
    when ver == "tag" && fk == "title" && title == "untitled" then false
    when ver == "inv" && (fk == "artist_type_id" || fk == "title" || fk == "dim_type_id") then false
    when ver == "tag" && fk == "title" && item_type.medium_key == "sculpturemedium" then false
    when fk == "mount_type_id" && fk_to_meth(fk).mount_key == "wrapped" && item_type.valid_keys.exclude?("canvas") then false
    when ver == "tag" && fk == "mount_type_id" && fk_to_meth(fk).mount_value == "streched" then false
    when ver == "tag" && fk == "dim_type_id" && ! xl_dims then false
    when ver != "body" && fk == "edition_type_id" && properties["unnumbered"].present? then false
    when ver != "body" && fk == "sign_type_id" && fk_to_meth(fk).properties["signtype"].present? && fk_to_meth(fk).properties["signtype"] == "not numbered" then false
    when ver != "body" && fk == "cert_type_id" && fk_to_meth(fk).properties["certificate"].present? && fk_to_meth(fk).properties["certificate"] == "N/A" then false
    else true
    end
  end

  def present_item_attr?(v)
    item_attrs.include?(v) && public_send(v).present?
  end

  def valid_required_remote_key?(fk)
    fk_to_meth(fk).properties if fk_to_meth(fk)
  end

  def valid_required_local_key?(fk)
    fk_to_meth(fk).required_fields.keep_if {|f| valid_local_keys.include?(f)} == fk_to_meth(fk).required_fields if fk_to_meth(fk) && properties
  end

  def required_properties?(fk)
    local_keys.include?(fk) ? valid_required_local_key?(fk) : valid_required_remote_key?(fk)
  end

  def valid_ver_value?(ver, k)
    (present_item_attr?(k) && valid_type?(ver, k)) || (! item_attrs.include?(k) && required_properties?(k) && valid_type?(ver, k))
  end

  def ver_types(ver)
    all_keys.map {|k| fk_to_type(k) if valid_ver_value?(ver, k)}.compact
  end

  def reorder_title(build, ver)
    reorder_items(build, "title", "item", 0)
  end

  def reorder_artist(build, ver)
    if ver != "body"
      target = ver_types(ver).include?("title") ? "title" : "item"
      reorder_items(build, "artist", target, 0)
    end
  end

  def reorder_mount(build, ver)
    if ver != "body" && mount_type.mount_key == "framed"
      reorder_items(build, "mount", "item", 0)
    end
  end

  def ordered_keys(ver)
    build = []
    ver_types(ver).each do |typ|
      respond_to?("reorder_" + typ) && public_send("reorder_" + typ, build, ver) ? public_send("reorder_" + typ, build, ver) : build << typ
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
    h = {v: h[:v], str: h[:build],pos: "after", pat: item_type.xl_dim_ref, occ: 0, ws: 1}
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
    %w(item title sign edition cert disclaimer).include?(typ) || (typ == "artist" && ver != "body") || (typ == "mount" && mount_type.mount_context(ver) == "push") || (typ == "dim" &&  ver != "tag")
  end

  def assign_type(h, typ, ver)
    push_conditions(h, typ, ver) ? push_assign(h) : insert_rel_to_pat(public_send("assign_" + typ, h))
  end

  #check edit
  def build_type(h, typ, ver)
    local_keys.include?(typ + "_type_id") || typ == "sign" ? public_send("build_" + typ, h, typ, ver) : h[:v]
  end

  def typ_args(typ, ver)
    args = item_attrs.include?(typ) ? public_send(typ + "_" + ver + "_args") : type_to_meth(typ).typ_ver_args(ver)
    args.class == String ? h = {v: args} : args
  end

  def build_d(ver)
    h = {build: ""}
    ordered_keys(ver).each do |typ|
      build_type(h.merge!(typ_args(typ, ver)), typ, ver) if typ_args(typ, ver)
      punct_type(h, typ, ver) if %w(item edition sign cert).include?(typ)
      assign_type(h, typ, ver) if typ_args(typ, ver) && %w(item title mount artist edition sign cert dim disclaimer).include?(typ)
    end
    ver == "body" ? h[:build] : cap(h[:build])
  end

  def insert_retail(d)
    idx = d.index(".") + 1
    d.insert(idx, " #{retail_proom}")
  end

  def build_pr
    if item_type
      pr = retail_proom ? insert_retail(build_d("tag")) : build_d("tag")
      abbrv_description(pr, 128)
    end
  end

  def ringo_clause
    h = {tag: " (Protege of Andy Warhol's Apprentice - Steve Kaufman)", body: " - Protege of Andy Warhol's Apprentice - Steve Kaufman"}
  end

  def insert_artist_tag
    idx = idx_after_pat(build_d("tag"), 0, artist_type.display_name)
    build_d("tag").insert(idx, ringo_clause[:tag])
  end

  def build_inv
    if item_type
      d = build_d("inv")
      abbrv_description(d, 40)
    end
  end

  def tagline
    if item_type
      build_d("tag") #artist_id && artist_id == 7707 ? insert_artist_tag : build_d("tag")
    end
  end

  def property_room
    build_pr if item_type
  end

  def description
    if item_type
      build_d("body")
    end
  end

  def invoice_tag
    build_inv if item_type
  end
end
