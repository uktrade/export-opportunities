require 'rails_helper'

RSpec.describe 'Error routing' do
  before do
    allow(ActionController::Base).to receive(:allow_forgery_protection).and_return(true)
  end

  it 'routes /500 via GET' do
    get '/export-opportunities/500'
    expect(response).to have_http_status(500)
    expect(response.body).to include('This page is unavailable')
  end

  it 'routes /404 via GET' do
    get '/export-opportunities/404'
    expect(response).to have_http_status(404)
    expect(response.body).to include('This page cannot be found')
  end

  it 'routes /500 via POST' do
    post '/export-opportunities/500', params: { foo: 'bar' }
    expect(response).to have_http_status(500)
    expect(response.body).to include('This page is unavailable')
  end

  it 'routes /404 via POST' do
    post '/export-opportunities/404', params: { foo: 'bar' }
    expect(response).to have_http_status(404)
    expect(response.body).to include('This page cannot be found')
  end
end
