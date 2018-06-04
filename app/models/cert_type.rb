class CertType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def valid_keys
    properties.map {|k,v| k if v.present?}.compact if properties.present?
  end

  def required_keys?
   category_names.sort == valid_keys.sort if properties.present? && category
  end

  def valid_keys_include?(k)
    category_names.include?(k) if required_keys?
  end

  def key_valid_and_eql?(k, v)
    valid_keys_include?(k) && properties[k] == v
  end

  def key_value(k)
    properties[k] if valid_keys_include?(k)
  end

  #new: ver-specific or universal?
  def global_credential?(credential_k)
    %w(PSA/DNA N/A).exclude?(key_value(credential_k))
  end

  #new: elements for build loop
  def credential_keys
    %w(seal certificate) & valid_keys
  end

  #new: key/values for "x of authenticity" credentials
  def credential_hsh
    h = {s: "Seal", l: "Letter", c: "Certificate", p: "PSA/DNA", o: "Official Seal"}
  end

  #new:
  def authentication_value(credential_k)
    key_value(credential_k) == "PSA/DNA" ? "Authentication" : "of Authenticity"
  end

  #new: issuer dependency
  def issuer?(h)
    category_names.include?(h[:k][0..3] + "issuer")
  end

  #new: issuer dependency
  def build_issuer(h)
    v = key_value(h[:k][0..3] + "issuer")
    h[:ver] == "inv" ? "(#{v})" : "from #{v}"
  end

  #new: 4/4 for: credential_authentication_inverso_issuer
  def issuer(h)
    build_issuer(h) if issuer?(h)
  end

  #new: 3/3 for: credential_authentication_inverso_issuer
  def inverso(h)
   "inverso" if key_value(h[:k]).index("inverso")
  end

  #new: authentication dependency
  def build_authentication(h)
    key_value(h[:k]) == "PSA/DNA" ? "Authentication" : "of Authenticity"
  end

  #new: 2/4 of credential_authentication_inverso_issuer
  def authentication(h)
    build_authentication(h) unless key_value(h[:k]) == "official seal"
  end

  #new: body dependency
  def body_credential_hsh
    h = {p: "This piece is presented with PSA/DNA Authentication, which authenticates memorabilia using proprietary permanent invisible ink as well as a strand of synthetic DNA.", n: "This piece does not come with a Certificate of Authenticity."}
  end

  #new: credential dependency
  def global_credential_hsh
    h = {s: "Seal", l: "Letter", c: "Certificate", p: "PSA/DNA", o: "Official Seal"}
  end

  #new: 1/4 of credential_authentication_inverso_issuer
  def credential(h)
    k = key_value(h[:k])
    k = k[0].downcase.to_sym
    global_credential_hsh[k]
  end

  #new: 1/3 of combine elements
  def credential_authentication_inverso(h)
    [credential(h), authentication(h), inverso(h)].compact.join(" ")
  end

  #new: 2/3 of combine elements
  def credential_authentication_inverso_issuer(h)
    [credential_authentication_inverso(h), issuer(h)].compact.join(" ")
  end

  #new: 3/3 of combine elements
  def certificate_value(h)
    v = credential_authentication_inverso_issuer(h)
    h[:k] == "seal" && valid_keys_include?("certificate") ? "#{v} and" : v
  end

  def build_hsh
    h = {tag: "with", inv: "", body: "Includes"}
  end

  def initialize_build(h)
    build_hsh[h[:ver].to_sym]
  end

  # def punct_cert(h)
  #   #h[:build] + "."
  #   h[:ver] == "body" ? h[:build] + "." : h[:build]
  # end

  def build_cert(h)
    h[:build] = initialize_build(h)
    credential_keys.each do |k|
      h[:k] = k
      h[:build] << pad_pat_for_loop(h[:build], certificate_value(h))
    end
    # punct_cert(h)
    h[:build]
  end

  def route_to_target_method(h)
    case
    when h[:ver] == "body" && ! global_credential?(credential_keys[0]) then body_credential_hsh[key_value("certificate").downcase[0].to_sym]
    when h[:ver] == "inv" && key_valid_and_eql?("certificate", "N/A") then "(Cert N/A)"
    else build_cert(h)
    end
  end

  #use hsh
  def typ_ver_args(ver)
    route_to_target_method(h = {ver: ver})
  end

  #revisit
  def key_valid_and_included?(k)
    key_value(k) && authentication_list.include?(properties[k])
  end

  def dropdown
    typ_ver_args("inv")
  end
end
