class Sector < ApplicationRecord
  def to_param
    slug
  end
end
