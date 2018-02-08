class Country < ApplicationRecord
  scope :with_exporting_guide, -> { where.not(exporting_guide_path: nil) }
  has_many :service_providers
  belongs_to :region

  def to_param
    slug
  end
end
