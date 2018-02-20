class SignType < ApplicationRecord
  belongs_to :category
  has_many :items

  def description
    if properties.present?
      case
      when properties["signmethod"].present? && ["hand", "thumbprinted and hand"].include?(properties["signmethod"]) && properties["signtype"].present? && properties["signer"].present? then signed_by
      when properties["signmethod"].present? && properties["signmethod"] == "plate" then plate_signed
      when properties["signmethod"].present? && properties["signmethod"] == "estate" then estate_signed
      when properties["signmethod"].present? && properties["signmethod"] == "authorized" && properties["signtype"].present? && properties["signer"].present? then authorized_signature
      when properties["signmethod"] = "estate" && properties["signtype"].present? then estate_signed
      when properties["signtype"] == "not signed" then unsigned
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
    description[-1]
  end
end
