require 'rails_helper'

RSpec.describe Api::DocumentController, type: :controller do
  before :each do
    sign_in(create(:user))
    @params = {
      user_id: 1,
      original_filename: 'test_filename',
      file_blob: File.read('spec/files/tender_sample_file.txt'),
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
        post :create, format: :json, params: @params

        expect(response).to have_http_status(200)
      end

      it 'with invalid request params' do
        skip
      end

      it 'with AV server down' do
        skip('move to feature specs')
        allow(Figaro.env).to receive(:CLAM_AV_HOST).and_return('a-url-that-does-not-exist.com')
        post :create, format: :json, params: @params

        expect(response).to_not be_success
        expect(response.status).to be(422)
      end
    end
  end
end
