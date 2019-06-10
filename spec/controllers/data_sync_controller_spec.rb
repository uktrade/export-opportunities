require 'rails_helper'

RSpec.describe DataSyncController, type: :controller do
  describe 'routing' do
    it 'data sync check endpoint is publically accessible' do
      expect(get: '/export-opportunities/data_sync_check').to route_to(controller: 'data_sync', action: 'check')
    end
  end
end
