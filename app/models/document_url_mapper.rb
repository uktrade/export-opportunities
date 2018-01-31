class DocumentUrlMapper < ApplicationRecord
  include DeviseUserMethods

  belongs_to :user
  belongs_to :enquiry
end
