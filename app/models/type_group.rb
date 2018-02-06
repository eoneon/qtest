class TypeGroup < ApplicationRecord
  belongs_to :classifiable, polymorphic: true
  belongs_to :typeable, polymorphic: true
end
