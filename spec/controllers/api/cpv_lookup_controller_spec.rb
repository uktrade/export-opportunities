# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CpvLookupController, type: :controller do
  describe 'GET CPV lookup controller search' do
    context 'when request is not json' do
      it 'does not accept the call' do
        get :search, params: { description: 'hello' }

        expect(response).to have_http_status(406)
      end
    end

    context 'when request is json' do
      context 'when there are no params' do
        it 'does not return matches' do
          get :search, format: :json, params: {}

          expect(response).to have_http_status(404)
          expect(response.body).to eq(%({"detail":"Not found"}))
        end
      end

      context 'when there are params' do
        it 'handles the request' do
          get :search, format: :json, params: { description: 'hello' }

          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
