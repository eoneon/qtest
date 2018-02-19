class CertType < ApplicationRecord
  belongs_to :category
  has_many :items

  def cert_description
    [seal_clause, cert_clause].join(" ")
  end

  def seal_clause
    case
    when properties["seal"].present? && properties["sealissuer"].present? then ["bearing", properties["seal"], "from", properties["sealissuer"]].join(" ")
    end
  end

  def cert_clause
    case
    when authenticity.present? && properties["certissuer"].present? then [authenticity, "from", properties["certissuer"]].join(" ")
    when authenticity.present? && properties["certissuer"].blank? then authenticity
    end
  end

  def authenticity
    case
    when properties["certificate"] == "COA" then "Certificate of Authenticity"
    when properties["certificate"] == "LOA" then "Letter of Authenticity"
    end
  end
end
