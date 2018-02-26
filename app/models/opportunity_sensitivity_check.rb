class OpportunitySensitivityCheck < ApplicationRecord
  belongs_to :opportunity
  has_many :opportunity_sensitivity_term_checks
end
