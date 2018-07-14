class Invoice < ApplicationRecord
  belongs_to :supplier, optional: true
  has_many :items, dependent: :destroy
  has_many :notes, as: :noteable, dependent: :destroy

  def inv_skus
    self.items.order(:sku).pluck(:sku)
  end

  def supplier_name
    supplier.name if supplier
  end
end
