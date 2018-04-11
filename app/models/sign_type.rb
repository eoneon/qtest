class SignType < ApplicationRecord
  include SharedMethods
  
  belongs_to :category
  has_many :items

  def valid_types
    attribute_names.map {|k| validate_properties(k) if k.index(/_type_id/) && public_send(k).present?}.compact
  end

  def sign
    if properties.present?
      case
      when properties["signmethod"].present? && ["hand", "thumbprinted and hand"].include?(properties["signmethod"]) && properties["signtype"].present? && properties["signer"].present? then signed_by
      when properties["signmethod"].present? && properties["signmethod"] == "plate" then plate_signed
      when properties["signmethod"].present? && properties["signmethod"] == "estate" then estate_signed
      when properties["signmethod"].present? && properties["signmethod"] == "authorized" && properties["signtype"].present? && properties["signer"].present? then authorized_signature
      when properties["signtype"].present? && properties["signtype"] == "not signed" then unsigned
      end
    end
  end

  def signed_by
    ["#{properties["signmethod"]} #{properties["signtype"]}", "#{properties["signmethod"]} #{properties["signtype"]} by the #{properties["signer"]}"]
  end

  def plate_signed
    ["signed", "bearing the #{properties["signmethod"]} signature of the #{properties["signer"]}"]
  end

  def estate_signed
    ["signed", "estate signed"]
  end

  def authorized_signature
    ["signed", "bearing the #{properties["signmethod"]} signature of the #{properties["signer"]}"]
  end

  def unsigned
    ["This piece is unsiged."]
  end

  def dropdown
    sign[-1] if properties.present?
  end

  def typ_ver_args(ver)
    sign[-1] if sign.present?
  end
end
