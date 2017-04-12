class Country < ActiveRecord::Base
  scope :with_exporting_guide, -> { where.not(exporting_guide_path: nil) }

  def to_param
    slug
  end
end
