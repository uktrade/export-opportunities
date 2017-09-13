require 'rails_helper'

# These tests require internet connection to the S3 bucket

RSpec.describe DocumentStorage do
  it 'stores a file into S3' do
    doc = 'spec/files/tender_sample_file.txt'
    params = {
      filename: 'test_filename',
    }
    DocumentStorage.new.call(params[:filename], doc)
  end
end
