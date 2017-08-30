require 'rails_helper'

RSpec.describe DocumentUrlShortener do
  it 'shortens a link' do
    DocumentUrlShortener.new.shorten_and_save_link('https://s3.amazonaws.com/export-opportunities-test-bucket/test_file', 1, 1, 'test_file')
  end

  it 'gets a shortened link from the S3 url' do
    document_url_shortener = DocumentUrlShortener.new.shorten_and_save_link('https://s3.amazonaws.com/export-opportunities-test-bucket/test_file', 1, 1, 'test_file')
    res = DocumentUrlShortener.new.s3_link(1, 1, document_url_shortener.hashed_id)

    expect(res.s3_link).to eq 'https://s3.amazonaws.com/export-opportunities-test-bucket/test_file'
  end
end
