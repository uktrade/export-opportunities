require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'routing' do
    it 'check endpoint is publically accessible' do
      expect(get: '/check').to route_to(controller: 'application', action: 'check')
    end
  end
end
