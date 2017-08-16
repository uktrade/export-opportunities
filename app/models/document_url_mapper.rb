class DocumentUrlMapper < ActiveRecord::Base
  include DeviseUserMethods

  belongs_to :user
  belongs_to :enquiry
end
