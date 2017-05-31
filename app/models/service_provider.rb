class ServiceProvider < ActiveRecord::Base
  has_many :editors
  belongs_to :country
end
