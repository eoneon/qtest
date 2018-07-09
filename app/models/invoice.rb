class Invoice < ApplicationRecord
  has_many :items, dependent: :destroy

  def inv_skus
    self.items.order(:sku).pluck(:sku)
  end
end
