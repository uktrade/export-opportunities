class ServiceProvider < ApplicationRecord
  has_many :editors, dependent: :nullify
  has_many :opportunities
  belongs_to :country
end
