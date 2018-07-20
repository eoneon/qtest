module InvoicesHelper
  def inv_skus
    @invoice.ordered_skus.pluck(:sku)
  end

  def sku_count
    inv_skus.count
  end

  def first_sku
    inv_skus[0]
  end

  def last_sku
    inv_skus[-1]
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

  def sequential_sub_range(h, idx)
    sku_rng = []
    inv_skus.drop(inv_skus.index(inv_skus[idx])).each do |sku|
      abs_idx = inv_skus.index(sku)
      if sku_rng.empty? || prev_sku_sequential?(abs_idx)
        sku_rng << sku
      end
    end
    h[:last] = sku_rng[-1]
    format_sku_rng(sku_rng)
  end

  def format_skus
    h = {skus: [], last: ""}
    inv_skus.each.with_index do |sku, idx|
      next if sku <= h[:last].to_i
      if next_sku_sequential?(idx)
        h[:skus] << sequential_sub_range(h, idx)
      else
        h[:skus] << sku
        h[:last] = sku
      end
    end
    h[:skus].join(", ")
  end

  def display_inv_skus
    if inv_skus.first.present?
      if sequential_range?
        format_sku_rng([inv_skus[0], inv_skus[-1]])
      else
        format_skus
      end
    end
  end
end
