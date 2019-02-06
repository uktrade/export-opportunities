class ServiceProvider < ApplicationRecord
  has_many :editors, dependent: :nullify
  belongs_to :country
end
