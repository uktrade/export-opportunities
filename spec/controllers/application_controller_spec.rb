require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'routing' do
    it 'check endpoint is publically accessible' do
      expect(get: '/check').to route_to(controller: 'application', action: 'check')
    end

    it 'data sync check endpoint is publically accessible' do
      expect(get: '/data_sync_check').to route_to(controller: 'application', action: 'data_sync_check')
    end

    it 'api check endpoint is publically accessible' do
      expect(get: '/api_check').to route_to(controller: 'application', action: 'api_check')
    end
  end
end
