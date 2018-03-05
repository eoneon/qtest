class EditionType < ApplicationRecord
  belongs_to :category
  has_many :items

  def category_names
    category.name.split("_")
  end

  def dropdown
    case
    when category_names.count == 4 then "numbered x/y"
    when category_names.count == 3 then "numbered from edion size"
    when category_names.count == 2 then "numbered x/y qty"
    when category_names == ["edition"] then "from an edition"
    when category_names == ["unnumbered"] then "not numbered"
    end
  end
end
