class ServiceProvider < ApplicationRecord
  has_many :editors
  belongs_to :country

end
