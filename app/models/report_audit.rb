class ReportAudit < ActiveRecord::Base
  belongs_to :editor
  include DeviseUserMethods
end
