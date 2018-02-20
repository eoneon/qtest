class CertType < ApplicationRecord
  belongs_to :category
  has_many :items

  def context
    if properties.present?
      case
      when seal_clause.present? && cert_clause.nil? then "seal"
      when seal_clause.nil? && cert_clause.present? then "cert"
      when seal_clause.present? && cert_clause.present? then "seal_cert"
      end
    end
  end

  def seal_clause
    if properties["seal"].present? && properties["sealissuer"].present?
      ["#{properties["seal"]} from #{properties["sealissuer"]}", "This piece bears the #{properties["seal"]} from #{properties["sealissuer"]}"].reject {|i| i.nil?}
    end
  end

  def cert_clause
    if authenticity.present? && properties["certissuer"].present?
      ["#{authenticity} from #{properties["certissuer"]}"]
    elsif authenticity.present? && properties["certissuer"].blank?
      [authenticity]
    end
  end

  def authenticity
    if properties["certificate"] == "COA"
      "certificate of authenticity"
    elsif properties["certificate"] == "LOA"
      "letter of authenticity"
    end
  end

  def description
    if properties.present?
      case
      when context == "seal" then ["with #{seal_clause[0]}", "#{seal_clause[-1]}."]
      when context == "cert" then ["with #{cert_clause[0]}", "Includes #{cert_clause[-1]}."]
      when context == "seal_cert" then ["with #{seal_clause[0]} and #{cert_clause[-1]}", "#{seal_clause[-1]} and includes #{cert_clause[-1]}."]
      end
    end
  end

  def dropdown
    if properties.present?
      case
      when context == "seal" then seal_clause[0]
      when context == "cert" then cert_clause[0]
      when context == "seal_cert" then "#{seal_clause[0]} & #{cert_clause[0]}"
      end
    end
  end
end
