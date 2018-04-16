class SignType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def valid_keys
    properties.map {|k,v| k if v.present?}.compact if properties.present?
  end

  def required_keys?
   category_names.sort == valid_keys.sort
  end

  def sign_context
    case
    when properties["signmethod"] &&  arr_match?(properties["signmethod"].split(" "), ["hand", "autographed"]) then "hand_signed"
    when properties["signmethod"] && %w(plate authorized estate).include?(properties["signmethod"]) then properties["signmethod"] + "_signed"
    when properties["signtype"] && properties["signtype"] == "not signed" then "unsigned"
    end
  end

  def hand_signed(ver,k)
    case
    when %w(tag inv).include?(ver) && k != "signer" then properties[k]
    when ver == "body" && k == "signtype" then "#{properties[k]} by the"
    when ver == "body" && k != "signtype" then properties[k]
    when ver == "inv" && k != "signer" then properties[k]
    end
  end

  def plate_signed(ver,k)
    case
    when %w(tag inv).include?(ver) && k != "signer" then properties[k]
    when ver == "body" && k == "signmethod" then "bearing the " + properties[k] + " signature of the"
    when ver == "body" && k != "signtype" then properties[k]
    end
  end

  def authorized_signed(ver,k)
    case
    when ver == "tag" && k == "signtype" then return properties[k]
    when ver == "inv" && k == "signmethod" then return "signed (#{properties[k]})"
    when ver == "body" && k == "signmethod" then "bearing the " + properties[k] + " signature of the"
    when ver == "body" && k == "signer" then properties[k]
    end
  end

  def estate_signed(ver, k)
    case
    when ver == "tag" && k == "signtype" then return properties[k]
    when ver == "inv" && k == "signmethod" then return "signed (#{properties[k]})"
    when ver == "body" then properties[k]
    end
  end

  def unsigned(ver, k)
    case
    when ver == "inv" then "(unsigned)"
    when ver == "body" then return "This piece is not signed."
    end
  end

  def build_sign(ver)
    sign = []
    category_names.each do |k|
      sign << public_send(sign_context, ver, k) if sign_context
    end
    sign.join(" ")
  end

  def typ_ver_args(ver)
    build_sign(ver) if required_keys?
  end

  def dropdown
    build_sign("inv") if required_keys?
  end
end
