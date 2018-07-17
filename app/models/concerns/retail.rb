require 'active_support/concern'

module Retail
  extend ActiveSupport::Concern
  def raw_retail
    number_with_precision(retail, precision: 2, delimiter: ',')
  end

  def retail_inv
    number_to_currency(retail, precision: 0, delimiter: ',') if retail.present? &&  retail > 0
  end

  def retail_proom
    "List #{retail_inv}" if retail && retail > 0
  end
end
