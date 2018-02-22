class DimType < ApplicationRecord
  belongs_to :category
  has_many :items

  def category_names
    category.name.split("_")
  end

  def name=(name)
    write_attribute(:name, category.name)
  end

  def dropdown
    category_names.join(" + ")
  end
end
