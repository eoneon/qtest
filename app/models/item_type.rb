class ItemType < ApplicationRecord
  include Importable

  belongs_to :category
end
