module ItemsHelper
  def inv_items
    @item.invoice.items.order(:sku)
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

  def last_item(inv_items)
    inv_items[-1]
  end

  def sku_nav(item)
    if inv_items.present?
      idx = inv_items.index(item)
      h = {prev_item: prev_item(idx, inv_items), next_item: next_item(idx, inv_items), first_item: first_item(inv_items), last_item: last_item(inv_items)}
    end
  end
end
