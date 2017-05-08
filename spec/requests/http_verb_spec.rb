require 'rails_helper'

RSpec.describe 'HTTP verbs', :elasticsearch, :commit, type: :request do
  it 'return 200 status for GET /check' do
    get '/check'
    expect(response).to have_http_status(200)
  end

  it 'return 200 status for HEAD /check' do
    head '/check'
    expect(response).to have_http_status(200)
  end

  it 'returns 406 status for GET /opportunities with unhandled format' do
    get '/opportunities.pdf'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for GET / with unhandled mime-type' do
    get '/', '', 'ACCEPT': 'application/pdf'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for HEAD /opportunities with unhandled format' do
    head '/opportunities.pdf'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for GET /opportunities with unregistered format' do
    get '/opportunities.zzz'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for GET / with unregistered mime-type' do
    get '/', '', 'ACCEPT': 'application/x-zzz'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for HEAD /opportunities with unhandled format' do
    head '/opportunities.zzz'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for HEAD / with unregistered mime-type' do
    head '/', '', 'ACCEPT': 'application/x-zzz'
    expect(response).to have_http_status(406)
  end

  it 'returns 404 status for POST /check' do
    post '/check'
    expect(response).to have_http_status(404)
  end
end
