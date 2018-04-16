class CertType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def valid_keys
    properties.map {|k,v| k if v.present?}.compact if properties.present?
  end

  def required_keys?
   category_names.sort == valid_keys.sort if properties.present?
  end

  def seal?
    category_names.include?("seal") if required_keys?
  end

  def cert?
    category_names.include?("certificate") if required_keys?
  end

  def seal_and_cert?
    seal? && cert?
  end

  def certissuer?
    category_names.include?("certissuer")
  end

  def sealissuer?
    category_names.include?("sealissuer")
  end

  def issuer?
    certissuer? || sealissuer?
  end

  def inverso?
    properties["seal"] == "SOA inverso" if required_keys?
  end

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
    inverso? ? format_inverso(cert_arr) : cert_arr
  end

  def na_clause
    "this piece does not come with a Certificate of Authenticity"
  end

  def psa_clause
    "this piece is presented with PSA/DNA Authentication, which authenticates memorabilia using proprietary permanent invisible ink as well as a strand of synthetic DNA"
  end

  def format_coa(k)
    case properties[k]
    when "COA" then "certificate"
    when "LOA" then "letter"
    when "SOA" then "seal"
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
    when %(COA LOA SOA).include?(properties[k]) then format_coa(k) + " of authenticity"
    when properties[k] == "PSA/DNA" && %(tag inv).include?(ver) then properties[k] + " authentication"
    when properties[k] == "PSA/DNA" && ver == "body" then psa_clause
    else properties[k]
    end
  end

  def build_cert(ver)
    cert = []
    cert << format_cert(ver)
    key_loop.each do |k|
      return unless required_keys?
      return na_clause if properties[k] == "N/A"
      cert << cert_context(ver, k)
    end
    cert.join(" ")
  end

  def typ_ver_args(ver)
    build_cert(ver) if required_keys?
  end

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
    drop = []
    drop_loop.each do |k|
      drop << format_drop(k)
    end
    drop.join(" ")
  end
end
