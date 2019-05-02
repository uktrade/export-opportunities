require 'rails_helper'

RSpec.describe 'CSRF behaviour', type: :request do
  before do
    @old_forgery_protection_value = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = @old_forgery_protection_value
  end

  it 'shows a human-readable error when CSRF token is invalid' do
    post '/export-opportunities/admin/editors/sign_in', params: { authenticity_token: 'rubbish' }
    expect(response).to have_http_status(422)
    expect(response.body).to include('Your session timed out')
  end

  it 'notifies Sentry with exception data' do
    expect(Raven).to receive(:capture_exception)
    post '/export-opportunities/admin/editors/sign_in', params: { authenticity_token: 'rubbish' }
  end
end
