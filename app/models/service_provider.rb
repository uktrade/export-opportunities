class ServiceProvider < ApplicationRecord
  has_many :editors, dependent: :nullify
  has_many :opportunities, dependent: :nullify
  belongs_to :country
end
