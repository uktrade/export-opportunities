require 'rails_helper'

RSpec.describe 'HTTP verbs', :elasticsearch, :commit, type: :request do
  it 'return 200 status for GET /check' do
    get '/export-opportunities/check'
    expect(response).to have_http_status(200)
  end

  it 'return 200 status for GET /api_check' do
    get '/export-opportunities/api_check'
    expect(response).to have_http_status(200)
  end

  it 'return 200 status for HEAD /check' do
    head '/export-opportunities/check'
    expect(response).to have_http_status(200)
  end

  it 'returns 406 status for GET /opportunities with unhandled format' do
    get '/export-opportunities/opportunities.pdf'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for GET / with unhandled mime-type' do
    get '/export-opportunities/', params: {}, headers: { 'ACCEPT': 'application/pdf' }
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for HEAD /opportunities with unhandled format' do
    head '/export-opportunities/opportunities.pdf'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for GET /opportunities with unregistered format' do
    get '/export-opportunities/opportunities.zzz'
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for GET / with unregistered mime-type' do
    get '/export-opportunities/', params: {}, headers: { 'ACCEPT': 'application/x-zzz' }
    expect(response).to have_http_status(406)
  end

  it 'returns 406 status for HEAD /opportunities with unhandled format' do
    head '/export-opportunities/opportunities.zzz'
    expect(response).to have_http_status(406)
  end

  it 'returns 404 status for POST /check' do
    post '/export-opportunities/check'
    expect(response).to have_http_status(404)
  end
end
