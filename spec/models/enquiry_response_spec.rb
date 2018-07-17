require 'rails_helper'

RSpec.describe EnquiryResponse do
  describe 'validations' do
    subject { FactoryBot.build(:enquiry_response) }
    it { is_expected.to belong_to :enquiry }
    it { is_expected.to belong_to :editor }

    context 'when the form is invalid' do
      it 'has empty email body form' do
        invalid_enquiry_response_details = { response_type: '1', email_body: '', signature: 'fake sig', enquiry_id: '12345' }

        enquiry_response = EnquiryResponse.new(invalid_enquiry_response_details)
        enquiry_response.valid?

        expect(enquiry_response).to have(1).error_on(:email_body)
      end
    end
  end
end
