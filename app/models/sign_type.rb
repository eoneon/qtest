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

  ##properties_values
  def signmethod
    properties["signmethod"] if valid_keys.include?("signmethod")
  end

  def signtype
    properties["signtype"] if valid_keys.include?("signtype")
  end

  def signer
    properties["signer"] if valid_keys.include?("signer")
  end

  #unsigned?
  def signtype_eql?(v)
    signtype && signtype == v
  end

  #hand_signed?
  def signmethod_include?(v)
    signmethod && signmethod.split(" ").include?(v)
  end

  #context-specific: signed, autographed
  def tag_signmethod_value
    signtype if signmethod_include?("autgraphed") || signmethod_include?("authorized")
  end

  def tag_signmethod_signtype_value
    [signmethod, signtype].join(" ") if signmethod_include?("hand") || signmethod_include?("plate") || signmethod_include?("estate")
  end

  def tag_value
    [tag_signmethod_signtype_value, tag_signmethod_value].compact[0] if tag_signmethod_signtype_value || tag_signmethod_value
  end

  #inv
  def inv_authorized_value
    "signed (authorized)" if signmethod_include?("authorized")
  end

  def inv_unsigned_value
    "(unsigned)" if signtype_eql?("not signed")
  end

  def parenth_signed
    [inv_authorized_value, inv_unsigned_value].compact[0] if signmethod_include?("authorized") || signtype_eql?("not signed")
  end

  def inv_value
    [parenth_signed, tag_value].compact[0] if parenth_signed || tag_value
  end

  #body
  def body_hand_signed
    [tag_signmethod_signtype_value, "by the", signer].join(" ") if signmethod_include?("hand")
  end

  def body_proxy_signed
    ["bearing the", tag_signmethod_signtype_value.sub("sign", "signature"), "of the", signer].join(" ") if signmethod_include?("authorized") || signmethod_include?("plate") || signmethod_include?("estate")
  end

  def body_unsigned
   "This piece is not signed." if signtype_eql?("not signed")
  end

  def body_value
   [body_hand_signed, body_proxy_signed, body_unsigned].compact[0]
  end
  ##end

  # def sign_context
  #   case
  #   when properties["signmethod"] &&  arr_match?(properties["signmethod"].split(" "), ["hand", "autographed"]) then "hand_signed"
  #   when properties["signmethod"] && %w(plate authorized estate).include?(properties["signmethod"]) then properties["signmethod"] + "_signed"
  #   when properties["signtype"] && properties["signtype"] == "not signed" then "unsigned"
  #   end
  # end
  #
  # def hand_signed(ver,k)
  #   case
  #   when %w(tag inv).include?(ver) && k != "signer" then properties[k]
  #   when ver == "body" && k == "signtype" then "#{properties[k]} by the"
  #   when ver == "body" && k != "signtype" then properties[k]
  #   when ver == "inv" && k != "signer" then properties[k]
  #   end
  # end
  #
  # def plate_signed(ver,k)
  #   case
  #   when %w(tag inv).include?(ver) && k != "signer" then properties[k]
  #   when ver == "body" && k == "signmethod" then "bearing the " + properties[k] + " signature of the"
  #   when ver == "body" && k != "signtype" then properties[k]
  #   end
  # end
  #
  # def authorized_signed(ver,k)
  #   case
  #   when ver == "tag" && k == "signtype" then return properties[k]
  #   when ver == "inv" && k == "signmethod" then return "signed (#{properties[k]})"
  #   when ver == "body" && k == "signmethod" then "bearing the " + properties[k] + " signature of the"
  #   when ver == "body" && k == "signer" then properties[k]
  #   end
  # end
  #
  # def estate_signed(ver, k)
  #   case
  #   when ver == "tag" && k == "signtype" then return properties[k]
  #   when ver == "inv" && k == "signmethod" then return "signed (#{properties[k]})"
  #   when ver == "body" then properties[k]
  #   end
  # end
  #
  # def unsigned(ver, k)
  #   case
  #   when ver == "inv" then "(unsigned)"
  #   when ver == "body" then return "This piece is not signed."
  #   end
  # end
  #
  # def build_sign(ver)
  #   sign = []
  #   category_names.each do |k|
  #     sign << public_send(sign_context, ver, k) if sign_context
  #   end
  #   sign.join(" ")
  # end

  # def typ_ver_args(ver)
  #   build_sign(ver) if required_keys?
  # end

  #1
  def typ_ver_args(ver)
    public_send(ver + "_value") if required_keys?
  end

  def dropdown
    #build_sign("inv") if required_keys?
    inv_value if required_keys?
  end
end
