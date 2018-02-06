class Category < ApplicationRecord
  include Importable

  has_many :type_groups, as: :classifiable, dependent: :destroy
  has_many :item_types, through: :type_groups, source: :typeable, source_type: 'ItemType'
  has_many :edition_types, through: :type_groups, source: :typeable, source_type: 'EditionType'
  has_many :sign_types, through: :type_groups, source: :typeable, source_type: 'SignType'
  has_many :cert_types, through: :type_groups, source: :typeable, source_type: 'CertType'
  has_many :dim_types, through: :type_groups, source: :typeable, source_type: 'DimType'

  def classifiable_type=(sType)
     super(sType.to_s.classify.constantize.base_class.to_s)
  end

  #call this inside Category controller
  def category_names
    self.classifiable_type.constantize.all
  end
end
