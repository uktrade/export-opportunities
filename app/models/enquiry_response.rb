class EnquiryResponse < ActiveRecord::Base
  belongs_to :enquiry
  belongs_to :editor
end
