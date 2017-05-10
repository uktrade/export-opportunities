require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'routing' do
    it 'check endpoint is publically accessible' do
      expect(get: '/check').to route_to(controller: 'application', action: 'check')
    end

    it 'data sync check endpoint is publically accessible' do
      expect(get: '/data_sync_check').to route_to(controller: 'application', action: 'data_sync_check')
    end
  end

  describe 'data sync' do
    skip('TBD')
    it 'returns ok if data is in sync' do
      # expect_any_instance_of(es_opportunities(:any)).to receive(:any).and_return ['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de']
      allow(ApplicationController).to receive(:es_opportunities).and_return(['8c11755c-3c39-44cd-8b4e-7527bbc7aa10', '5bb688c2-391e-490a-9e4b-d0183040e9de'])

      get :data_sync_check
    end
    it 'returns error if data is not in sync' do
    end
  end
end
