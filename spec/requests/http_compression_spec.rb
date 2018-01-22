require 'rails_helper'

RSpec.feature 'HTTP Compression', type: :request do
  scenario 'visitor has a browser that supports compression' do
  skip('Rails 5')
    ['deflate', 'gzip', 'deflate,gzip', 'gzip,deflate'].each do |method|
      get opportunities_path, params: {}, headers: { 'HTTP_ACCEPT_ENCODING': method }

      expect(response.headers['Content-Encoding']).not_to be_nil
    end
  end

  scenario 'visitor has a browser that does not support compression' do
    get opportunities_path

    expect(response.headers['Content-Encoding']).to be_nil
  end
end
