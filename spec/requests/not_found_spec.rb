require 'rails_helper'

RSpec.describe 'nonexistent pages' do
  it 'returns a 404 for html' do
    get '/export-opportunities/foo'
    expect(response).to have_http_status(404)
    expect(response.header['Content-Type']).to include 'text/html'
    expect(response.body).to include('This page cannot be found')
  end

  it 'returns a 404 for js' do
    get '/export-opportunities/foo.js'
    expect(response).to have_http_status(404)
    expect(response.body).to be_empty
  end

  it 'returns a 404 for json' do
    get '/export-opportunities/foo.json'
    expect(response).to have_http_status(404)
    expect(response.header['Content-Type']).to include 'application/json'
    expect(JSON.parse(response.body)).to eq('errors' => 'Resource not found')
  end

  it 'returns a 404 for xml' do
    get '/export-opportunities/foo.xml'
    expect(response).to have_http_status(404)
    expect(response.header['Content-Type']).to include 'application/xml'
    expect(response.body).to be_empty
  end

  it 'returns a 404 for unknown formats' do
    get '/export-opportunities/foo.wibble'
    expect(response).to have_http_status(404)
    expect(response.body).to be_empty
  end
end
