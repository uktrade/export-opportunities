class EnquiryResponse < ActiveRecord::Base
  has_many :response_documents, dependent: :destroy
  accepts_nested_attributes_for :response_documents

  validates :email_body, length: { minimum: 30, message: 'You need at least 30 characters in your reply' }
  belongs_to :enquiry
  belongs_to :editor
end
