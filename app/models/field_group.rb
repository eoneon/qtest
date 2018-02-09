class FieldGroup < ApplicationRecord
  belongs_to :category
  belongs_to :item_field
  default_scope {order('sort ASC')}
  attr_accessor :item_field_ids
  before_save :set_sort

  def set_sort
    self.sort = category.name.split("_").index(item_field.name) #if elementable.present?
  end
end
