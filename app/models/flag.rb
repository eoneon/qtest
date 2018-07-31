class Flag < ApplicationRecord
  has_many :items

  enum flag: [:ready, :done]
end
