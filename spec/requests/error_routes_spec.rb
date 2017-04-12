require 'rails_helper'

RSpec.describe 'Error routing' do
  before do
    allow(ActionController::Base).to receive(:allow_forgery_protection).and_return(true)
  end

  it 'routes /500 via GET' do
    get '/500'
    expect(response).to have_http_status(500)
    expect(response.body).to include('Sorry, something went wrong')
  end

  it 'routes /404 via GET' do
    get '/404'
    expect(response).to have_http_status(404)
    expect(response.body).to include('Sorry, page not found')
  end

  it 'routes /500 via POST' do
    post '/500', foo: 'bar'
    expect(response).to have_http_status(500)
    expect(response.body).to include('Sorry, something went wrong')
  end

  it 'routes /404 via POST' do
    post '/404', foo: 'bar'
    expect(response).to have_http_status(404)
    expect(response.body).to include('Sorry, page not found')
  end
end
