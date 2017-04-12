class Value < ActiveRecord::Base
  validates :slug, uniqueness: true

  def to_param
    slug
  end
end
