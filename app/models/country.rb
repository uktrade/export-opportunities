class Country < ApplicationRecord
  scope :with_exporting_guide, -> { where.not(exporting_guide_path: nil) }
  has_many :service_providers, dependent: :nullify
  belongs_to :region
  attribute :opportunity_count, :integer, default: 0

  def to_param
    slug
  end
end
