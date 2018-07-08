module ItemsHelper
  def inv_items
    Item.where(invoice_id: @item.invoice_id).order(:sku)
  end

  def inv_skus
    inv_items.pluck(:sku)
  end

  def prev_item(idx, inv_items)
    idx == 0 ? inv_items[0] : inv_items[idx - 1]
  end

  def next_item(idx, inv_items)
    last_item(inv_items) == inv_items[idx] ? inv_items[idx] : inv_items[idx + 1]
  end

  def first_item(inv_items)
    inv_items[0]
  end

  # def last_item(inv_items)
  #   inv_items[-1]
  # end

  ##
  def first_sku
    #inv_items[0].sku
    inv_skus[0]
  end

  def last_sku
    inv_skus[-1]
  end

  def last_item(inv_items)
    inv_items[-1]
  end

  def last_idx
    inv_skus.index(last_sku)
  end

  def sku_count
    inv_skus.count
  end

  def sequential_range?
    last_sku - first_sku == last_idx
  end

  def next_sku_sequential?(idx)
    inv_skus[idx] + 1 == inv_skus[idx + 1]
  end

  def prev_sku_sequential?(idx)
    idx == 0 || inv_skus[idx] - 1 == inv_skus[idx -1]
  end

  def format_sku_rng(sku_rng)
    [sku_rng[0], sku_rng[-1]].uniq.join("-")
  end

  def sku_nav(item)
    idx = inv_items.index(item)
    h = {prev_item: prev_item(idx, inv_items), next_item: next_item(idx, inv_items), first_item: first_item(inv_items), last_item: last_item(inv_items)}
  end
end
