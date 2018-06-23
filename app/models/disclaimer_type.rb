class DisclaimerType < ApplicationRecord
  include SharedMethods

  belongs_to :category
  has_many :items

  def required_fields
    %w(disclaimer defect category)
  end

  def typ_ver_args(ver)
    h = {v: category_names}
  end

  def dropdown
    "Disclaimer"
  end
end
