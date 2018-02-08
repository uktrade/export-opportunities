class Type < ApplicationRecord
  scope :aid_funded, -> { where(slug: 'aid-funded-business') }

  def to_param
    slug
  end
end
