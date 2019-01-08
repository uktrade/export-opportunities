class Sector < ApplicationRecord
  scope :featured, -> { where(featured: true).order(:featured_order) }

  def to_param
    slug
  end
end
