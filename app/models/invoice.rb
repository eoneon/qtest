class Invoice < ApplicationRecord
  belongs_to :supplier, optional: true
  has_many :items, dependent: :destroy
  has_many :notes, as: :noteable, dependent: :destroy

  def ordered_skus
    items.order(:sku)
  end

  def sku_pos(item)
    ordered_skus.index(item) + 1
  end

  def supplier_name
    supplier.name if supplier
  end
end
