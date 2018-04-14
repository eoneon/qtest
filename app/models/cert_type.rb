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
    "This piece does not come with a Certificate of Authenticity."
  end

  def psa_clause
    "This piece is presented with PSA/DNA Authentication, which authenticates memorabilia using proprietary permanent invisible ink as well as a strand of synthetic DNA."
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
  # def coa?(k)
  #   %w(certificate seal).include?(k) && properties[k][1..2] == "OA"
  # end

  # def cert_and_issuer?
  #   %w(certificate certissuer).all? {|k| category_names.include?(k)} if required_keys?
  # end

  # def cert_only?
  #   category_names[-1] == "certificate"
  # end
  # def conj(ver)
  #   ver == "tag" ? "with" : "includes"
  # end

  # def format_coa(k)
  #   case
  #   when is_coa?(k)
  # end

  # def context
  #   if properties.present?
  #     case
  #     when seal_clause.present? && cert_clause.nil? then "seal"
  #     when seal_clause.nil? && cert_clause.present? then "cert"
  #     when seal_clause.present? && cert_clause.present? then "seal_cert"
  #     end
  #   end
  # end
  #
  # def seal_clause
  #   if properties["seal"].present? && properties["sealissuer"].present?
  #     ["#{properties["seal"]} from #{properties["sealissuer"]}", "This piece bears the #{properties["seal"]} from #{properties["sealissuer"]}"].reject {|i| i.nil?}
  #   end
  # end
  #
  # def cert_clause
  #   if authenticity.present? && properties["certissuer"].present?
  #     ["#{authenticity} from #{properties["certissuer"]}"]
  #   elsif authenticity.present? && properties["certissuer"].blank?
  #     [authenticity]
  #   end
  # end
  #
  # def authenticity
  #   if properties["certificate"] == "COA"
  #     "certificate of authenticity"
  #   elsif properties["certificate"] == "LOA"
  #     "letter of authenticity"
  #   end
  # end
  #
  # def description
  #   if properties.present?
  #     case
  #     when context == "seal" then ["with #{seal_clause[0]}", "#{seal_clause[-1]}."]
  #     when context == "cert" then ["with #{cert_clause[0]}", "Includes #{cert_clause[-1]}."]
  #     when context == "seal_cert" then ["with #{seal_clause[0]} and #{cert_clause[-1]}", "#{seal_clause[-1]} and includes #{cert_clause[-1]}."]
  #     end
  #   end
  # end

  # def dropdown
  #   format_drop(k)
  #   if properties.present?
  #     case
  #     when context == "seal" then seal_clause[0]
  #     when context == "cert" then cert_clause[0]
  #     when context == "seal_cert" then "#{seal_clause[0]} & #{cert_clause[0]}"
  #     end
  #   end
  # end
end
