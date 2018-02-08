class Medium < Category
  has_many :item_fields, through: :field_groups
end
