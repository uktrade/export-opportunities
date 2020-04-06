class Sector < ApplicationRecord
  scope :featured, -> { where(featured: true).order(:featured_order) }

  scope :visible, -> { where.not(hidden: true) }

  def to_param
    slug
  end
end
