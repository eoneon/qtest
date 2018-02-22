class EditionType < ApplicationRecord
  belongs_to :category
  has_many :items

  def category_names
    category.name.split("_")
  end

  def dropdown
    category_names.join(" + ")
  end
end
