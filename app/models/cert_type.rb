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
    #key_value(credential_k).index(/[\/]/).nil? if key_value(credential_k)
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
    h[:ver] == "inv" ? "(#{v})" : v
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
    h = {p: "This piece is presented with PSA/DNA Authentication, which authenticates memorabilia using proprietary permanent invisible ink as well as a strand of synthetic DNA", n: "This piece does not come with a Certificate of Authenticity"}
  end

  #new: credential dependency
  def global_credential_hsh
    h = {s: "Seal", l: "Letter", c: "Certificate", p: "PSA/DNA", o: "Official Seal"}
  end

  #new: 1/4 of credential_authentication_inverso_issuer
  def credential(h)
    k = key_value(h[:k]) #[0].downcase
    k = k[0].downcase.to_sym
    global_credential_hsh[k]
  end

  #new: 1/3 of combine elements
  def credential_authentication_inverso(h)
    [credential(h), authentication(h), inverso(h)].compact.join(" ")
  end

  #new: 2/3 of combine elements
  def credential_authentication_inverso_issuer(h)
    delim = issuer?(h) ? " from " : " "
    [credential_authentication_inverso(h), issuer(h)].compact.join(delim)
  end

  #new: 3/3 of combine elements
  def certificate_value(h)
    v = credential_authentication_inverso_issuer(h)
    h[:k] == "seal" && valid_keys_include?("certificate") ? "#{v} and" : v
  end

  #here!
  def build_hsh
    h = {tag: "with", inv: "", body: "Includes"}
  end

  def initialize_build(h)
    build_hsh[h[:ver].to_sym]
  end

  def build_cert(h)
    h[:build] = initialize_build(h)
    credential_keys.each do |k|
      h[:k] = k
      h[:build] << pad_pat_for_loop(h[:build], certificate_value(h))
    end
    h[:build]
  end

  # def clause_credential?(credential_k)
  #   key_value(credential_k) == "PSA/DNA" || key_value(credential_k) == "N/A"
  # end

  def route_to_target_method(h)
    h[:ver] == "body" && ! global_credential?(credential_keys[0]) ? body_credential_hsh[key_value("certificate").downcase[0].to_sym] : build_cert(h)
  end

  #use hsh
  def typ_ver_args(ver)
    route_to_target_method(h = {ver: ver})
  end

  #kill
  def authentication_list
    %w(SOA LOA COA PSA/DNA)
  end

  #kill
  def authentication_values
    %w(Seal Letter Certificate PSA/DNA)
  end

  def key_valid_and_included?(k)
    key_value(k) && authentication_list.include?(properties[k])
  end

  #kill
  def authentication_hsh
    h = {c: "Certificate of Authenticity", s: "Seal of Authenticity", l: "Letter of Authenticity", p: "PSA/DNA Authenticated"}
  end

  def tag_certificate
    authentication_hsh[key_value("certificate")[0].downcase] if key_valid_and_included?("certificate")
  end

  # def tag_authentication(k)
  #   format_tag_authentication(k) key_valid_and_included?(k)
  # end

  #kill: valid_keys_include?
  def seal?
    category_names.include?("seal") if required_keys?
  end

  #kill: valid_keys_include?
  def cert?
    category_names.include?("certificate") if required_keys?
  end

  #kill: valid_keys_include?
  def seal_and_cert?
    #seal? && cert?
    valid_keys_include?("seal") && valid_keys_include?("certificate")
  end

  #kill: valid_keys_include?
  def certissuer?
    category_names.include?("certissuer")
  end

  #kill: valid_keys_include?
  def sealissuer?
    category_names.include?("sealissuer")
  end

  #kill: valid_keys_include?
  # def issuer?
  #   certissuer? || sealissuer?
  # end

  #kill: key_valid_and_eql?
  # def inverso?
  #   properties["seal"] == "SOA inverso" if required_keys?
  # end

  #kill: key_valid_and_eql?
  def na?
    properties["certificate"] == "N/A" if required_keys?
  end

  def join_seal_cert(d)
    v = d == "descrp" ? "and" : "&"
    insert_rel_to_i(arr: category_names, pos: "after", i: "sealissuer", v: v, occ: 0)
  end

  def format_issuer(arr, issuer)
    insert_rel_to_i(pos: "before", arr: arr, i: issuer, v: "from", occ: 0)
  end

  def key_loop
    cert_arr = seal_and_cert? ? join_seal_cert("descrp") : category_names
    cert_arr = certissuer? ? format_issuer(cert_arr, "certissuer") : cert_arr
    cert_arr = sealissuer? ? format_issuer(cert_arr, "sealissuer") : cert_arr
    #inverso? ? format_inverso(cert_arr) : cert_arr
  end

  def na_clause
    "This piece does not come with a Certificate of Authenticity"
  end

  def psa_clause
    "This piece is presented with PSA/DNA Authentication, which authenticates memorabilia using proprietary permanent invisible ink as well as a strand of synthetic DNA"
  end

  def format_coa(k)
    case properties[k]
    when "COA" then "Certificate"
    when "LOA" then "Letter"
    when "SOA" then "Seal"
    end
  end

  def format_cert(ver)
    case
    when %(tag inv).include?(ver) then "with"
    when ver == "body" && seal? then "Presented with"
    when ver == "body" && seal? == false then "Includes"
    end
  end

  def cert_context(ver, k)
    case
    when category_names.exclude?(k) then k
    when %(COA LOA SOA).include?(properties[k]) then format_coa(k) + " of Authenticity"
    when properties[k] == "PSA/DNA" && %(tag inv).include?(ver) then properties[k] + " Authentication"
    when properties[k] == "PSA/DNA" && ver == "body" then psa_clause
    else properties[k]
    end
  end

  # def build_cert(ver)
  #   cert = []
  #   cert << format_cert(ver)
  #   key_loop.each do |k|
  #     return unless required_keys?
  #     return na_clause if properties[k] == "N/A"
  #     cert << cert_context(ver, k)
  #   end
  #   cert.join(" ")
  # end
  #
  # def typ_ver_args(ver)
  #   build_cert(ver) if required_keys?
  # end

  def format_drop(k)
    case
    when category_names.exclude?(k) then k
    when %(seal certificate).include?(k) then properties[k]
    when k.index("issuer") then "(#{properties[k]})"
    end
  end

  def drop_loop
    seal_and_cert? ? join_seal_cert("drop") : category_names
  end

  def dropdown
    category_names
  #   drop = []
  #   drop_loop.each do |k|
  #     drop << format_drop(k)
  #   end
  #   drop.join(" ")
  end
end
