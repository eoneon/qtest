class Item < ApplicationRecord
  belongs_to :item_type
  belongs_to :edition_type
end
