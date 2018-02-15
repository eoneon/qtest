class SignType < ApplicationRecord
  belongs_to :category
  has_many :items

  def sign_description
    case
    when ["hand", "estate"].include?(properties["signmethod"]) && properties["signtype"].present? && properties["signer"].present? then signed_by
    when ["plate", "authorized"].include?(properties["signmethod"]) && properties["signtype"].present? && properties["signer"].present? then bearing_signature
    when properties["signtype"] == "not signed" then unsigned
    end
  end

  def signed_by
    [properties["signmethod"], properties["signtype"], "by the", properties["signer"]].join(" ")
  end

  def bearing_signature
    ["bearing the", properties["signmethod"], "signature of the", properties["signer"]].join(" ")
  end

  def unsigned
    ["This piece is unsiged."]
  end
end
