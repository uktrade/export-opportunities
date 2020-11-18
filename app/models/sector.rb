class Sector < ApplicationRecord
  scope :featured, -> { where(featured: true).order(:featured_order) }

  scope :visible, -> { where(hidden: [nil, false]) }

  def to_param
    slug
  end
end
