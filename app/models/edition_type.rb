class EditionType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def valid_keys
    properties.keep_if {|k,v| v.present?} if properties.present?
  end

  def key_value(k)
    properties[k] if valid_keys.include?(k)
  end

  def key_value_eql?(k, v)
    valid_keys.include?(k) && properties[k] == v
  end

  def required_fields
    category_names.count == 1 ? category_names : category_names - ["edition"]
  end

  def edition_context
    category.name == "edition" ? "from_edition" : "not_from_edition"
  end

  def edition_numbered_number_size
    ["numbered", "edition numbered number/size"]
  end

  def edition_numbered_size
    ["numbered out of", "edition numbered out of size"]
  end

  def edition_numbered
    ["numbered qty", "edition numbered"]
  end

  def edition
    ["from an edition", "from edition edition"]
  end

  def unnumbered
    ["not numbered", "This piece is not numbered"]
  end

  def dropdown
    public_send(category.name)[0]
  end

  def typ_ver_args(ver)
    public_send(category.name)[1]
  end
end
