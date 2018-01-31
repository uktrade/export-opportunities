class ReportAudit < ApplicationRecord
  belongs_to :editor
  include DeviseUserMethods
end
