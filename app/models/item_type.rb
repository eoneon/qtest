class ItemType < ApplicationRecord
  include Importable
  
  has_many :type_groups, as: :typeable, dependent: :destroy
  has_many :artkinds, through: :type_groups, source: :classifiable, source_type: 'Category'
  has_many :media, through: :type_groups, source: :classifiable, source_type: 'Category'

  accepts_nested_attributes_for :type_groups, reject_if: proc {|attrs| attrs['classifiable_id'].blank?}, allow_destroy: true
end
