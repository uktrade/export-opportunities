class Region < ApplicationRecord
  has_many :countries, dependent: :nullify
end
