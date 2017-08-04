require 'rails_helper'

RSpec.describe Api::DocumentController, type: :controller do
  before :each do
    sign_in(create(:user))
    @params = {
      user_id: 1,
      enquiry_id: 2,
      original_filename: 'test_filename',
      file_blob: File.open('spec/files/tender_sample_file.txt', 'rb'),
    }
  end

  describe 'POST document controller create' do
    context 'creates new shortened link' do
      it 'with valid fakeapi request' do
        post :create, format: :json, params: @params

        expect(response).to have_http_status(200)
        # expect(response.body).to include('$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H')
      end

      it 'with valid real request' do
        # TODO: test without network connection. fails at logging.
        post :create, format: :json, enquiry_response: @params

        expect(response).to have_http_status(200)
        expect(response.body).to include('/dashboard/downloads/')
      end
    end
  end
end
