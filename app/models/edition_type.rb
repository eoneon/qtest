class EditionType < ApplicationRecord
  belongs_to :category

  def category_names
    category.name.split("_")
  end
end
