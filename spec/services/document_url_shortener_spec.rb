require 'rails_helper'

RSpec.describe DocumentUrlShortener do
  it 'shortens a link' do
    DocumentUrlShortener.new.shorten_link('https://s3.amazonaws.com/export-opportunities-test-bucket/test_file', 1, 1, 'test_file')
  end

  it 'gets a shortened link from the S3 url' do
    DocumentUrlShortener.new.shorten_link('https://s3.amazonaws.com/export-opportunities-test-bucket/test_file', 1, 1, 'test_file')
    res = DocumentUrlShortener.new.s3_link(1, 1, 'test_file')

    expect(res.s3_link).to eq 'https://s3.amazonaws.com/export-opportunities-test-bucket/test_file'
  end
end
