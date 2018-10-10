class SupplierPreference < ApplicationRecord
  validates :slug, uniqueness: true

  def to_param
    slug
  end
end
