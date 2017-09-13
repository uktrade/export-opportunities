require 'rails_helper'

RSpec.describe EnquiryResponse do
  describe 'validations' do
    subject { FactoryGirl.build(:enquiry_response) }
    it { is_expected.to belong_to :enquiry }
    it { is_expected.to belong_to :editor }

    context 'when the form is invalid' do
      it 'has less than 30 chars in email form' do
        skip('TODO: reintroduce when we raise the limit back to 30 chars')
        invalid_enquiry_response_details = { response_type: '1', email_body: '01234567890123456789012345678', signature: 'fake sig', enquiry_id: '12345' }

        enquiry_response = EnquiryResponse.new(invalid_enquiry_response_details)
        enquiry_response.valid?

        expect(enquiry_response).to have(1).error_on(:email_body)
      end
    end
  end
end
